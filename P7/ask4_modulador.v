module ask4_modulador(
	input wire clk_50M,   		// clk de 50M Placa
	input wire rst,				// Resete
	input wire [7:0] adc_data,	// Dados no mcp
	input wire data_valid,   	// Sinal de termino da conversao
	
	output reg ask4_pwm_out		// Saida modulada em 4-AKS
);

// 1. RELÓGIO DE SÍMBOLOS (800 Baud)
    // 50 MHz / 800 = 62.500 ciclos por símbolo
	reg [15:0] cnt_sym;
	reg sym_tick;

	always @(posedge clk_50M or negedge rst) begin
		 if (!rst) begin
			cnt_sym <= 0;
			sym_tick <= 0;
		 end else begin
			if (data_valid) begin
				cnt_sym <= 0;
				sym_tick <= 0;
			end else if (cnt_sym == 62499) begin
				cnt_sym <= 0;
				sym_tick <= 1'b1;
			end else begin
				cnt_sym <= cnt_sym + 1'b1;
				sym_tick <= 1'b0;
			end
		end
	end
	
	
	// 2. SHIFT REGISTER (Extrai 2 bits por vez)
	reg [7:0] shift_reg;
	reg [1:0] current_sym;

	always @(posedge clk_50M or negedge rst) begin
		if (!rst) begin
			shift_reg <= 8'b0;
			current_sym <= 2'b00;
		end else begin
			if (data_valid) begin
				current_sym <= adc_data[7:6]; // Pega os 2 mais significativos
				shift_reg <= {adc_data[5:0], 2'b00};
			end else if (sym_tick) begin
				current_sym <= shift_reg[7:6]; // Pega os 2 seguintes
				shift_reg <= {shift_reg[5:0], 2'b00};
			end
		end
	end

	// 3. PORTADORA PWM E MAPA DE SÍMBOLOS (100 kHz)
	reg [8:0] cnt_100k;
	reg [8:0] duty;

	always @(*) begin
		case(current_sym)
			2'b00: duty = 9'd0;    // Nível 0: 0% do ciclo (Contagem 0)
			2'b01: duty = 9'd35;   // Nível 1: 11% do ciclo (Contagem 55)
			2'b10: duty = 9'd95;  // Nível 2: 23% do ciclo (Contagem 115)
			2'b11: duty = 9'd250;  // Nível 3: 50% do ciclo (Contagem 250)
			default: duty = 9'd0;
		endcase
	end

	always @(posedge clk_50M or negedge rst) begin
		if (!rst) begin
			cnt_100k <= 0;
			ask4_pwm_out <= 0;
		end else begin
			if (cnt_100k == 499)
				cnt_100k <= 0;
			else
				cnt_100k <= cnt_100k + 1'b1;

			// Compara para gerar o PWM dinâmico
			if (cnt_100k < duty)
				ask4_pwm_out <= 1'b1;
			else
				ask4_pwm_out <= 1'b0;
		end
	end

endmodule 