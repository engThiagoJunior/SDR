// Compara o ciclo util do DDS com m(t). As frequencias sao aceleradas 100 vezes
// para que um periodo caiba em uma simulacao curta.
`timescale 1ns/1ps
module tb_dds_pwm;
    reg clk = 0, rst = 0;
    wire pwm;
    always #10 clk = ~clk;

    top_dds_pwm #(
        .PHASE_INC1(32'd4294967),
        .PHASE_INC2(32'd8589935)
    ) dut (.clk_50(clk), .rst(rst), .pwm_out(pwm));

    real t1, t2, esperado, erro, pi;
    integer amostras = 0, falhas = 0;

    always @(negedge clk)
        if (rst && dut.rom_valid && amostras < 1100) begin
            amostras = amostras + 1;
            if (amostras > 10) begin
                t1 = dut.phase1 / 4294967296.0;
                t2 = dut.phase2_off / 4294967296.0;
                esperado = (3.0*$cos(2.0*pi*t1) + 2.0*$cos(2.0*pi*t2) + 5.0) * 499.0 / 10.0;
                erro = dut.duty_reg - esperado;
                // A tolerancia cobre a latencia do pipeline nesta velocidade acelerada.
                if (erro > 10.0 || erro < -10.0) falhas = falhas + 1;
            end
        end

    initial begin
        pi = 3.141592653589793;
        #1000 rst = 1;
        wait (amostras == 1100);
        if (falhas == 0) $display("PASS tb_dds_pwm: %0d amostras", amostras);
        else $display("FAIL tb_dds_pwm: %0d amostras fora da tolerancia", falhas);
        $finish;
    end
endmodule
