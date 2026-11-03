module signal_summer #(
    parameter integer IN_WIDTH  = 16,
    parameter integer OUT_WIDTH = 16
)(
    input  wire signed [IN_WIDTH-1:0] in1,
    input  wire signed [IN_WIDTH-1:0] in2,
    output wire signed [OUT_WIDTH-1:0] sum_out
);

    assign sum_out = in1 + in2;

endmodule 