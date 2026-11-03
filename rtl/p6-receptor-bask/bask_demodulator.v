module bask_demodulator (
    input wire clk_50M,
    input wire rst,
    input wire envelope_out, // Saida do detector de envelope, amplificado
 
    output reg data_ready,
    output reg [7:0] rx_data
);

    // SINCRONIZADOR DE ENTRADA
    reg rx_sync_1, rx_sync_2, rx_sync_3;
	 
    always @(posedge clk_50M) begin
        rx_sync_1 <= envelope_out;
        rx_sync_2 <= rx_sync_1;
        rx_sync_3 <= rx_sync_2;
    end
	 
    // Detector de Borda
    wire edge_detect = (rx_sync_2 != rx_sync_3);
	 

    reg [14:0] bit_timer;
    reg sample_tick;

	 // RECUPERAÇÃO DE RELÓGIO PARA 1600 bps
    // 50 MHz / 1600 = 31250 ciclos por bit
    // O meio do bit ocorre no ciclo 15625
    always @(posedge clk_50M or negedge rst) begin
        if (!rst) begin
            bit_timer <= 0;
            sample_tick <= 0;
        end else begin
            sample_tick <= 1'b0;
            
            if (edge_detect)
                bit_timer <= 0;
            else if (bit_timer == 15'd31249)
                bit_timer <= 0;
            else
                bit_timer <= bit_timer + 1'b1;
				
            if (bit_timer == 15'd15625)
                sample_tick <= 1'b1;
        end
    end

    // MÁQUINA DE ESTADOS - 8 estados
    // O protocolo nao tem marcador de inicio de quadro. O valor inicial 2
    // alinha os bytes quando transmissor e receptor saem do mesmo reset.
    reg [3:0] bit_cnt = 2;
    reg [7:0] shift_reg;

    always @(posedge clk_50M or negedge rst) begin
        if (!rst) begin
            bit_cnt <= 2;
            shift_reg <= 0;
            rx_data <= 0;
            data_ready <= 0;
        end else begin
            data_ready <= 1'b0;

            
            if (sample_tick) begin
					shift_reg <= {shift_reg[6:0], rx_sync_2};
                
					if (bit_cnt == 3'd7) begin
						bit_cnt <= 0;
						rx_data <= shift_reg;
						data_ready <= 1'b1;
					end else begin
						bit_cnt <= bit_cnt + 1'b1;
               end
            end
        end
    end
endmodule 