// Modelo comportamental do MCP3002: entrega um valor pseudoaleatorio a cada
// conversao e registra o comando recebido.
module mcp3002_model(
    input  wire cs,
    input  wire sclk,
    input  wire din,
    output reg  dout
);
    reg [9:0] valor = 0;
    reg [3:0] comando = 0;
    integer pulsos = 0;
    integer semente = 7;

    initial dout = 1'b1;

    always @(negedge cs) begin
        valor = $random(semente);
        pulsos = 0;
    end

    always @(posedge sclk)
        if (!cs) begin
            pulsos = pulsos + 1;
            if (pulsos <= 4)
                comando = {comando[2:0], din};
        end

    always @(negedge sclk)
        if (!cs) begin
            if (pulsos == 4)
                dout = 1'b0;                 // bit nulo
            else if (pulsos >= 5 && pulsos <= 14)
                dout = valor[14 - pulsos];   // B9 a B0
        end
endmodule
