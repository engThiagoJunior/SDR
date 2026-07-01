module top_receptor_final (
    input wire clk_50M,
    input wire rst,
    input wire envelope_out, 		// Saida do detector de envelope, amplificado
    
    output wire pino_pwm_dac     // Entrada Filtro Passa-Baixa
);

    wire [7:0] byte_recebido;
    wire byte_pronto;

    // DEMODULADOR: Pega os bits do Amp-Op e monta o número de 0 a 255
    bask_demodulator receptor (
        .clk_50M (clk_50M),
        .rst (rst),
        .envelope_out(envelope_out),
        .rx_data (byte_recebido),
        .data_ready (byte_pronto)
    );

	 // GERADOR PWM: Varia o duty 
    pwm_generator #(
        .PWM_PERIOD(256),    				// Vai contar de 0 a 255 -256 passos
        .COUNTER_WIDTH(8)    				// 8 bits
    ) dac_saida (
        .clk (clk_50M),
        .rst (rst),
        .duty (byte_recebido), 			// O valor demodulado
        .pwm_out (pino_pwm_dac), 		// Sinal -> Entrada Filtro Passa-Baixa
        .period_tick ()               	// Pino nn usado nessa etapa
    );

endmodule 