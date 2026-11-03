// Modelo de simulacao da ROM de cosseno. Substitui o altsyncram do Quartus.
module ROM_sin(
    input  wire [9:0]  address,
    input  wire        clock,
    output reg  [11:0] q
);
    reg [11:0] mem [0:1023];
    integer i, valor;
    real amostra;

    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            amostra = 2047.0 * $cos(2.0 * 3.141592653589793 * i / 1024.0);
            valor = $rtoi(amostra >= 0.0 ? amostra + 0.5 : amostra - 0.5);
            mem[i] = valor[11:0];
        end
    end

    always @(posedge clock)
        q <= mem[address];
endmodule
