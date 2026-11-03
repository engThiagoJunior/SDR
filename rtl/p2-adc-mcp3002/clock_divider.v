module clock_divider(
    input  wire clk_50M,
    input  wire rst,
    output reg  clk_50k = 0,
    output reg  clk_200Hz = 0
);

    // Divisor para 50 kHz
    // Período total = 50M / 50k = 1000 ciclos.
    // Inverte a cada 500 ciclos (conta de 0 a 499)
    reg [8:0] cnt_50k = 0;
    always @(posedge clk_50M or negedge rst) begin
        if(!rst) begin
            cnt_50k <= 0;
            clk_50k <= 0;
        end else begin
            if (cnt_50k == 499) begin
                cnt_50k <= 0;
                clk_50k <= ~clk_50k;
            end else begin
                cnt_50k <= cnt_50k + 1;
            end
        end
    end

    // Divisor para 200 Hz
    // Período total = 50M / 200 = 250.000 ciclos.
    // Inverte a cada 125.000 ciclos (conta de 0 a 124.999)
    reg [16:0] cnt_200 = 0;
    always @(posedge clk_50M or negedge rst) begin
        if(!rst) begin
            cnt_200 <= 0;
            clk_200Hz <= 0;
        end else begin
            if (cnt_200 == 124999) begin
                cnt_200 <= 0;
                clk_200Hz <= ~clk_200Hz;
            end else begin
                cnt_200 <= cnt_200 + 1;
            end
        end
    end
    
endmodule 