// Verifica a selecao por SW0 e o caminho do receptor no modulo principal.
`timescale 1ns/1ps
module tb_top;
    reg clk = 0, rst = 0, modo_4ask = 0;
    always #10 clk = ~clk;

    wire cs, sclk, din, dout, pwm, modulado, demodulado;
    wire detector = dut.mod.current_bit;   // canal ideal

    mcp3002_model adc_model (.cs(cs), .sclk(sclk), .din(din), .dout(dout));

    PWM_MCP dut (
        .clk(clk), .rst(rst), .modo_4ask(modo_4ask),
        .ADC_CS(cs), .ADC_SCLK(sclk), .ADC_DIN(din), .ADC_DOUT(dout),
        .detector_ampOp(detector), .pwm_out(pwm),
        .pwm_bask_out(modulado), .pwm_bask_demodulacao(demodulado)
    );

    integer erros = 0, bordas_pwm = 0, bytes = 0;
    reg [7:0] anterior = 0, atual = 0;
    reg pwm_ant = 0;

    always @(negedge clk)
        if (rst && modulado !== (modo_4ask ? dut.pwm_ask4 : dut.pwm_bask))
            erros = erros + 1;

    always @(posedge clk) begin
        pwm_ant <= pwm;
        if (pwm != pwm_ant) bordas_pwm = bordas_pwm + 1;
        if (dut.data_valid_out && !dut.mod.cnt_bit) begin
            if (atual !== dut.adc_data_out) begin
                anterior = atual;
                atual = dut.adc_data_out;
            end
        end
        if (dut.receptor.byte_pronto) begin
            bytes = bytes + 1;
            if (bytes > 3 && dut.receptor.byte_recebido !== anterior)
                erros = erros + 1;
        end
    end

    initial begin
        #1000 rst = 1;
        wait (bytes == 8);
        modo_4ask = 1;
        #10000000;
        if (erros == 0 && bordas_pwm > 0) $display("PASS tb_top: %0d bytes recebidos", bytes);
        else $display("FAIL tb_top: %0d erros", erros);
        $finish;
    end
endmodule
