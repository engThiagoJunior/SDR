module top_dds_pwm #(
    parameter integer PHASE_WIDTH = 32,
    parameter integer LUT_ADDR_WIDTH = 10,
    parameter integer LUT_DATA_WIDTH = 12,
    parameter integer INTERNAL_WIDTH = 16,

    parameter integer PWM_PERIOD = 500,
    parameter integer PWM_WIDTH = 9,
    parameter integer PWM_MAX = 499,

    parameter [PHASE_WIDTH-1:0] PHASE_INC1 = 32'd42950,
    parameter [PHASE_WIDTH-1:0] PHASE_INC2 = 32'd85899,
    parameter [PHASE_WIDTH-1:0] PHASE_OFFSET = 32'd357913941
)(
    input  wire clk_50,
    input  wire rst,
    output wire pwm_out
    // output wire ref_low
);

    //assign ref_low = 1'b0;

    wire [PWM_WIDTH-1:0] duty_reg_wire;
    wire period_tick;
    reg  [PWM_WIDTH-1:0] duty_reg;

    assign duty_reg_wire = duty_reg;

    pwm_generator #(
        .PWM_PERIOD(PWM_PERIOD),
        .COUNTER_WIDTH(PWM_WIDTH)
    ) u_pwm (
        .clk(clk_50),
        .rst(rst),
        .duty(duty_reg_wire),
        .pwm_out(pwm_out),
        .period_tick(period_tick)
    );

    wire [PHASE_WIDTH-1:0] phase1;
    wire [PHASE_WIDTH-1:0] phase2;
    wire [PHASE_WIDTH-1:0] phase2_off;

    phase_accumulator #(
        .PHASE_WIDTH(PHASE_WIDTH)
    ) u_phase1 (
        .clk(clk_50),
        .rst(rst),
        .enable(period_tick),
        .phase_inc(PHASE_INC1),
        .phase(phase1)
    );

    phase_accumulator #(
        .PHASE_WIDTH(PHASE_WIDTH)
    ) u_phase2 (
        .clk(clk_50),
        .rst(rst),
        .enable(period_tick),
        .phase_inc(PHASE_INC2),
        .phase(phase2)
    );

    phase_offset_adder #(
        .PHASE_WIDTH(PHASE_WIDTH),
        .PHASE_OFFSET(PHASE_OFFSET)
    ) u_phase_off (
        .phase_in(phase2),
        .phase_out(phase2_off)
    );

    reg [LUT_ADDR_WIDTH-1:0] addr1_reg;
    reg [LUT_ADDR_WIDTH-1:0] addr2_reg;

    always @(posedge clk_50 or negedge rst) begin
        if (!rst) begin
            addr1_reg <= {LUT_ADDR_WIDTH{1'b0}};
            addr2_reg <= {LUT_ADDR_WIDTH{1'b0}};
        end
        else if (period_tick) begin
            addr1_reg <= phase1[31:22];
            addr2_reg <= phase2_off[31:22];
        end
    end

    wire [LUT_DATA_WIDTH-1:0] rom1_q;
    wire [LUT_DATA_WIDTH-1:0] rom2_q;

    wire signed [LUT_DATA_WIDTH-1:0] cos1;
    wire signed [LUT_DATA_WIDTH-1:0] cos2;

    ROM_sin rom1 (
        .address(addr1_reg),
        .clock(clk_50),
        .q(rom1_q)
    );

    ROM_sin rom2 (
        .address(addr2_reg),
        .clock(clk_50),
        .q(rom2_q)
    );

    assign cos1 = $signed(rom1_q);
    assign cos2 = $signed(rom2_q);

    wire signed [INTERNAL_WIDTH-1:0] sig1_gain;
    wire signed [INTERNAL_WIDTH-1:0] sig2_gain;
    wire signed [INTERNAL_WIDTH-1:0] sum_sig;

    gain_block #(
        .IN_WIDTH(LUT_DATA_WIDTH),
        .OUT_WIDTH(INTERNAL_WIDTH),
        .GAIN(3)
    ) u_gain1 (
        .din(cos1),
        .dout(sig1_gain)
    );

    gain_block #(
        .IN_WIDTH(LUT_DATA_WIDTH),
        .OUT_WIDTH(INTERNAL_WIDTH),
        .GAIN(2)
    ) u_gain2 (
        .din(cos2),
        .dout(sig2_gain)
    );

    signal_summer #(
        .IN_WIDTH(INTERNAL_WIDTH),
        .OUT_WIDTH(INTERNAL_WIDTH)
    ) u_summer (
        .in1(sig1_gain),
        .in2(sig2_gain),
        .sum_out(sum_sig)
    );

    wire [PWM_WIDTH-1:0] duty_next;

    pwm_mapper #(
        .IN_WIDTH(INTERNAL_WIDTH),
        .PWM_WIDTH(PWM_WIDTH),
        .IN_MIN(-10235),
        .IN_MAX(10235),
        .PWM_MAX(PWM_MAX)
    ) u_mapper (
        .din(sum_sig),
        .duty(duty_next)
    );

    reg rom_valid;

    always @(posedge clk_50 or negedge rst) begin
        if (!rst)
            rom_valid <= 1'b0;
        else
            rom_valid <= period_tick;
    end

    always @(posedge clk_50 or negedge rst) begin
        if (!rst)
            duty_reg <= {PWM_WIDTH{1'b0}};
        else if (rom_valid)
            duty_reg <= duty_next;
    end

endmodule 