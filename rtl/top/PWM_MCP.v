module PWM_MCP(
	input wire clk,                    // Clock 50 MHz
	input wire rst,                    // Reset KEY0
	input wire modo_4ask,              // SW0: 0 = BASK, 1 = 4-ASK

	// Sinais do MCP3002
	output wire ADC_CS,                // CS do MCP3002
	output wire ADC_SCLK,              // Clock do MCP3002
	output wire ADC_DIN,               // DIN
	input  wire ADC_DOUT,              // DOUT do MCP3002

	// Sinal do detector de envelope apos o comparador
	input wire detector_ampOp,         // Saida do AmpOp

	output wire pwm_out,               // PWM DDS - sinal original
	output wire pwm_bask_out,          // PWM modulado (BASK ou 4-ASK)
	output wire pwm_bask_demodulacao   // PWM demodulado (~195 kHz) -> Filtro Passa-Baixa
);

	wire [7:0] adc_data_out;
	wire data_valid_out;
	wire pwm_bask;
	wire pwm_ask4;

	top_dds_pwm pwm (
		.clk_50(clk),
		.rst(rst),
		.pwm_out(pwm_out)
	);

	top_mcp3002 mcp (
		.clk(clk),
		.rst(rst),
		.ADC_CS(ADC_CS),
		.ADC_SCLK(ADC_SCLK),
		.ADC_DIN(ADC_DIN),
		.ADC_DOUT(ADC_DOUT),
		.adc_data_out(adc_data_out),
		.data_valid_out(data_valid_out)
	);

	bask_modulator mod (
		.clk_50M (clk),
		.rst (rst),
		.adc_data (adc_data_out),
		.data_valid (data_valid_out),
		.bask_pwm_out (pwm_bask)
	);

	ask4_modulador mod4 (
		.clk_50M (clk),
		.rst (rst),
		.adc_data (adc_data_out),
		.data_valid (data_valid_out),
		.ask4_pwm_out (pwm_ask4)
	);

	assign pwm_bask_out = modo_4ask ? pwm_ask4 : pwm_bask;

	top_receptor_final receptor (
		.clk_50M (clk),
		.rst (rst),
		.envelope_out (detector_ampOp),
		.pino_pwm_dac (pwm_bask_demodulacao)
	);

endmodule
