// Cadeia ADC -> modulador BASK -> demodulador com canal ideal.
`timescale 1ns/1ps
module tb_adc_bask;
    reg clk = 0, rst = 0;
    always #10 clk = ~clk;

    wire cs, sclk, din, dout, valid, tx, pronto;
    wire [7:0] adc, rx;

    mcp3002_model adc_model (.cs(cs), .sclk(sclk), .din(din), .dout(dout));

    top_mcp3002 controle (
        .clk(clk), .rst(rst), .ADC_CS(cs), .ADC_SCLK(sclk), .ADC_DIN(din),
        .ADC_DOUT(dout), .adc_data_out(adc), .data_valid_out(valid)
    );
    bask_modulator modulador (
        .clk_50M(clk), .rst(rst), .adc_data(adc), .data_valid(valid), .bask_pwm_out(tx)
    );
    bask_demodulator demodulador (
        .clk_50M(clk), .rst(rst), .envelope_out(modulador.current_bit),
        .rx_data(rx), .data_ready(pronto)
    );

    reg [7:0] enviados [0:63];
    reg [7:0] recebidos [0:63];
    integer n_env = 0, n_rec = 0, erros = 0, i;
    reg valid_ant = 0;

    always @(posedge clk) begin
        valid_ant <= valid;
        if (valid && !valid_ant) begin
            enviados[n_env] = adc;
            if (adc !== adc_model.valor[9:2] || adc_model.comando !== 4'b1101)
                erros = erros + 1;
            n_env = n_env + 1;
        end
        if (pronto) begin
            recebidos[n_rec] = rx;
            n_rec = n_rec + 1;
        end
    end

    initial begin
        #1000 rst = 1;
        wait (n_rec == 20);
        // A recepcao fica um quadro atras da amostra enviada.
        for (i = 3; i < 19; i = i + 1)
            if (recebidos[i] !== enviados[i - 1]) erros = erros + 1;
        if (erros == 0) $display("PASS tb_adc_bask: %0d bytes recebidos", n_rec);
        else $display("FAIL tb_adc_bask: %0d erros", erros);
        $finish;
    end
endmodule
