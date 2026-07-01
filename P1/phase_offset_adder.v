module phase_offset_adder #(
    parameter integer PHASE_WIDTH = 32,
    parameter [PHASE_WIDTH-1:0] PHASE_OFFSET = 32'd357913941
)(
    input  wire [PHASE_WIDTH-1:0] phase_in,
    output wire [PHASE_WIDTH-1:0] phase_out
);

    assign phase_out = phase_in + PHASE_OFFSET;

endmodule 