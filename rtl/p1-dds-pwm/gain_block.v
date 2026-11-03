module gain_block #(
    parameter integer IN_WIDTH  = 12,
    parameter integer OUT_WIDTH = 16,
    parameter integer GAIN      = 2
)(
    input  wire signed [IN_WIDTH-1:0]  din,
    output reg  signed [OUT_WIDTH-1:0] dout
);

    reg signed [OUT_WIDTH-1:0] din_ext;

    always @(*) begin
        // extensão de sinal da entrada para a largura de saída
        din_ext = din;

        case (GAIN)
            2: dout = din_ext <<< 1;
            3: dout = din_ext + (din_ext <<< 1);
            default: dout = din_ext;
        endcase
    end

endmodule 