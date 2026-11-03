#!/usr/bin/env bash
# Executa os testes com Icarus Verilog. Uso: ./sim/run.sh
set -u
raiz="$(cd "$(dirname "$0")/.." && pwd)"
saida="$(mktemp -d)"
trap 'rm -rf "$saida"' EXIT

rtl=$(find "$raiz/rtl" -name '*.v' ! -name 'ROM_sin.v')
falhou=0

for tb in tb_dds_pwm tb_adc_bask tb_ask4 tb_top; do
    if ! iverilog -g2012 -s "$tb" -o "$saida/$tb.vvp" \
        "$raiz/sim/$tb.v" "$raiz/sim/rom_sin_model.v" "$raiz/sim/mcp3002_model.v" $rtl; then
        echo "FAIL $tb: erro de compilacao"
        falhou=1
        continue
    fi
    resultado=$(vvp "$saida/$tb.vvp")
    echo "$resultado"
    echo "$resultado" | grep -q '^PASS' || falhou=1
done

exit $falhou
