module pwm_mapper #(
    parameter integer IN_WIDTH  = 16,
    parameter integer PWM_WIDTH = 9,
    parameter integer IN_MIN    = -10235,
    parameter integer IN_MAX    =  10235,
    parameter integer PWM_MAX   = 499
)(
    input  wire signed [IN_WIDTH-1:0] din,
    output reg  [PWM_WIDTH-1:0] duty
);

    integer scaled_value;
    integer din_int;

    always @(*) begin
        din_int = din;

        if (din_int <= IN_MIN) begin
            duty={PWM_WIDTH{1'b0}};
        end
        else if (din_int >= IN_MAX) begin
            duty=PWM_MAX[PWM_WIDTH-1:0];
        end
        else begin
            // Mapeamento linear
            scaled_value=((din_int - IN_MIN) * PWM_MAX) / (IN_MAX - IN_MIN);
            duty=scaled_value[PWM_WIDTH-1:0];
        end
    end

endmodule 