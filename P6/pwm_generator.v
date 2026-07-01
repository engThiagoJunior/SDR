module pwm_generator #(
    parameter integer PWM_PERIOD = 500,
    parameter integer COUNTER_WIDTH = 9
)(
    input  wire clk,
    input  wire rst,
    input  wire [COUNTER_WIDTH-1:0] duty,
    output reg  pwm_out,
    output reg  period_tick
);

    reg [COUNTER_WIDTH-1:0] counter;

    // Contador PWM
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= {COUNTER_WIDTH{1'b0}};
        end
        else begin
            if (counter == PWM_PERIOD-1)
                counter <= {COUNTER_WIDTH{1'b0}};
            else
                counter <= counter + 1'b1;
        end
    end

    // Sinais de saída
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            pwm_out     <= 1'b0;
            period_tick <= 1'b0;
        end
        else begin
            period_tick <= (counter == PWM_PERIOD-1);

            if (counter < duty)
                pwm_out <= 1'b1;
            else
                pwm_out <= 1'b0;
        end
    end

endmodule 