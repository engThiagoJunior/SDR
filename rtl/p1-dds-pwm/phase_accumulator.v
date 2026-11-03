module phase_accumulator #(
    parameter integer PHASE_WIDTH = 32
)(
    input  wire clk,
    input  wire rst,
    input  wire enable,
    input  wire [PHASE_WIDTH-1:0] phase_inc,
    output reg [PHASE_WIDTH-1:0] phase
);

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            phase <= {PHASE_WIDTH{1'b0}};
        end
        else if (enable) begin
            phase <= phase + phase_inc;
        end
    end

endmodule 