// Mede o ciclo util de cada simbolo 4-ASK na ordem de transmissao.
`timescale 1ns/1ps
module tb_ask4;
    reg clk = 0, rst = 0, valid = 0;
    reg [7:0] dado = 0;
    wire pwm;
    always #10 clk = ~clk;

    ask4_modulador dut (
        .clk_50M(clk), .rst(rst), .adc_data(dado), .data_valid(valid), .ask4_pwm_out(pwm)
    );

    function integer nivel(input [1:0] simbolo);
        case (simbolo)
            2'b00: nivel = 0;
            2'b01: nivel = 35;
            2'b10: nivel = 95;
            2'b11: nivel = 250;
        endcase
    endfunction

    integer b, s, c, altos, erros = 0;
    reg [7:0] bytes [0:2];

    initial begin
        bytes[0] = 8'h1B; bytes[1] = 8'hE4; bytes[2] = 8'hC6;
        #1000 rst = 1;
        for (b = 0; b < 3; b = b + 1) begin
            @(negedge clk); dado = bytes[b]; valid = 1;
            @(negedge clk); valid = 0;
            for (s = 0; s < 4; s = s + 1) begin
                repeat (20000) @(posedge clk);   // meio do simbolo
                altos = 0;
                for (c = 0; c < 500; c = c + 1) begin
                    @(posedge clk);
                    if (pwm) altos = altos + 1;
                end
                if (altos !== nivel(bytes[b][7 - 2*s -: 2])) erros = erros + 1;
                repeat (62000 - 20500 - 1) @(posedge clk);
            end
        end
        if (erros == 0) $display("PASS tb_ask4: 12 simbolos");
        else $display("FAIL tb_ask4: %0d simbolos errados", erros);
        $finish;
    end
endmodule
