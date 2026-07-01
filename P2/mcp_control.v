module mcp_control (
    input  wire clk_50k,      // Clock base
    input  wire sample_tick,  // Sinal de 200 Hz
    input  wire rst,

    output reg  CS,
    output reg  SCLK,
    output wire DIN,
    input  wire DOUT,

    output reg [7:0] adc_data,
    output reg       data_valid
);

    reg sample_tick_prev;
    wire tick_pulse = (sample_tick && !sample_tick_prev);

    localparam S_IDLE     = 2'd0,
               S_TRANSFER = 2'd1,
               S_DONE     = 2'd2;

    reg [1:0]  state;
    reg [3:0]  spi_cnt;       // Conta 15 ciclos de clock
    reg [14:0] shift_reg_in;  // Armazena tudo que entra pelo DOUT
    reg [3:0]  cmd_out;       // Armazena o comando que sai pelo DIN

    assign DIN = cmd_out[3];

    always @(posedge clk_50k or negedge rst) begin
        if (!rst) begin
            sample_tick_prev <= 1'b0;
            state            <= S_IDLE;
            CS               <= 1'b1;
            SCLK             <= 1'b0;
            spi_cnt          <= 0;
            shift_reg_in     <= 0;
            cmd_out          <= 0;
            adc_data         <= 0;
            data_valid       <= 0;
        end else begin
            sample_tick_prev <= sample_tick;
            
            data_valid <= 1'b0; 

            case (state)
                S_IDLE: begin
                    CS   <= 1'b1;
                    SCLK <= 1'b0;
                    
                    if (tick_pulse) begin
                        CS       <= 1'b0;     // Ativa o chip
                        cmd_out  <= 4'b1101;  // Carrega o comando (Start, SGL, CH0, MSBF)
                        spi_cnt  <= 0;
                        state    <= S_TRANSFER;
                    end
                end

                S_TRANSFER: begin
					 
                    SCLK <= ~SCLK;

                    if (SCLK == 1'b0) begin
                        shift_reg_in <= {shift_reg_in[13:0], DOUT};
                    end else begin
                        cmd_out <= {cmd_out[2:0], 1'b0};
                        if (spi_cnt == 4'd14) begin
                            state <= S_DONE;
                        end else begin
                            spi_cnt <= spi_cnt + 1'b1;
                        end
                    end
                end

                S_DONE: begin
                    CS <= 1'b1; // Desativa o chip e finaliza a transação
                    
                    // Extração dos 8 bits:
                    // shift_reg_in[10] é o Null bit
                    // shift_reg_in[9:0] são os 10 bits de dados
                    // shift_reg_in[9:2] pega os 8 MSBs truncando os 2 LSBs
                    adc_data   <= shift_reg_in[9:2]; 
                    data_valid <= 1'b1;
                    
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end
endmodule 
