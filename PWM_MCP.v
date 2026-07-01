module PWM_MCP(
	input wire clk, 						//Clock 50MHz
	input wire rst, 						//Reset KEY0
	
	// Sinais do MCP3002
   output wire ADC_CS,       			// CS do MCP3002
   output wire ADC_SCLK,     			// Clock do MCP3002
   output wire ADC_DIN,      			// DIN
   input  wire ADC_DOUT,     			// DOUT do MCP3002
	 
	// Sinal do detector de envelope amplificado
	input wire detector_ampOp,			// Saida do AmpOp
	
   // Saídas para debug 
   //output wire [7:0] adc_data_out,
   //output wire data_valid_out,
	
	output wire pwm_out,       		// Saida PWM DDS - SINAL ORIGINAL
	
	output wire pwm_bask_out,  		// Saide PWM BASK
	
	output wire pwm_bask_demodulacao // Saida PWM BASK DEMODULADO, COM PORADORA DE 100KHZ -> Filtro Passa-Baixa
	 
);

	wire [7:0] adc_data_out;
	wire data_valid_out;
	
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
	
//	bask_modulator mod (
//		.clk_50M (clk),
//		.rst (rst),
//		.adc_data (adc_data_out),
//		.data_valid (data_valid_out),
//		.bask_pwm_out (pwm_bask_out)
//	);
 
	ask4_modulador mod4(
		.clk_50M (clk),   		
		.rst (rst),				
		.adc_data (adc_data_out),	
		.data_valid (data_valid_out),   	
		
		.ask4_pwm_out(pwm_bask_out)		
	);
		
	
//	top_receptor_final receptor (
//		.clk_50M (clk),
//		.rst  (rst),
//		.envelope_out(detector_ampOp),
//		.pino_pwm_dac(pwm_bask_demodulacao)
//	);
	
endmodule 