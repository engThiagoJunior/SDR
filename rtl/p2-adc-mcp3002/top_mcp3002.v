module top_mcp3002(
    input  wire clk,     // Clock 50 MHz da DE0
    input  wire rst,     // Usaremos KEY0 como Reset (ativo baixo na DE0)
    
    // Sinais do MCP3002
    output wire ADC_CS,       // CS do MCP3002
    output wire ADC_SCLK,     // Clock do MCP3002
    output wire ADC_DIN,      // DIN (fixo em 1)
    input  wire ADC_DOUT,     // DOUT do MCP3002
    
    // Saídas para debug / próximo estágio
    output wire [7:0] adc_data_out,
    output wire       data_valid_out
);

    // Fios internos
    wire clk_50M;
    wire clk_50k;
    wire clk_200Hz;

    clock_divider div(
        .clk_50M   (clk),
        .rst       (rst),
        .clk_50k   (clk_50k),
        .clk_200Hz (clk_200Hz)
    );

    mcp_control mcp (
        .clk_50k      (clk_50k),
        .sample_tick  (clk_200Hz),
        .rst          (rst),
        .CS           (ADC_CS),
        .SCLK         (ADC_SCLK),
        .DIN          (ADC_DIN),
        .DOUT         (ADC_DOUT),
        .adc_data     (adc_data_out),
        .data_valid   (data_valid_out)
    );

endmodule 