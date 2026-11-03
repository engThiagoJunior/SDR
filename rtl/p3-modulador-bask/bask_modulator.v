module bask_modulator (
    input wire clk_50M,        // Clock 50 MHz
    input wire rst,
    input wire [7:0] adc_data, // Dado do mcp_control
    input wire data_valid,     // 200 Hz do mcp_control

    output wire bask_pwm_out   // Saída modulada
);
    // RELÓGIO DE BITS (1600 Hz)
    // 50 MHz / 1600 bps = 31.250 ciclos por bit
    reg [14:0] cnt_bit;
    reg bit_tick;

    always @(posedge clk_50M or negedge rst) begin
        if (!rst) begin
            cnt_bit <= 0;
            bit_tick <= 0;
        end else begin
            if (data_valid) begin
                cnt_bit <= 0;
                bit_tick <= 0;
            end else if (cnt_bit == 31249) begin
                cnt_bit <= 0;
                bit_tick <= 1'b1;
            end else begin
                cnt_bit <= cnt_bit + 1'b1;
                bit_tick <= 1'b0;
            end
        end
    end

    reg [7:0] shift_reg;
    reg current_bit;

    always @(posedge clk_50M or negedge rst) begin
        if (!rst) begin
            shift_reg <= 8'b0;
            current_bit <= 1'b0;
        end else begin
            if (data_valid) begin
                current_bit <= adc_data[7];
                shift_reg <= {adc_data[6:0], 1'b0};
            end else if (bit_tick) begin
                current_bit <= shift_reg[7];
                shift_reg <= {shift_reg[6:0], 1'b0};
            end
        end
    end

    // PORTADORA PWM (100 kHz)
    reg [8:0] cnt_100k;
    reg carrier;

    always @(posedge clk_50M or negedge rst) begin
        if (!rst) begin
            cnt_100k <= 0;
            carrier <= 0;
        end else begin
            if (cnt_100k == 499)
                cnt_100k <= 0;
            else
                cnt_100k <= cnt_100k + 1'b1;
					 
            carrier <= (cnt_100k < 250);
        end
    end

    // Modulação OOK/BASK: Bit 1 passa a portadora, Bit 0 zera a saída
    assign bask_pwm_out = current_bit ? carrier : 1'b0;

endmodule 