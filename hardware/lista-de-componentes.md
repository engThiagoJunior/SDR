# Lista de componentes

| Bloco | Referência | Componente | Observação |
|---|---|---|---|
| Plataforma | — | Terasic DE10-Lite | FPGA MAX 10 10M50DAF484C7G |
| Filtro passa-baixa de entrada | R1, C1 | 10 kΩ e 1 µF | Corte em cerca de 15,9 Hz |
| Conversor A/D | U1 | MCP3002 | 10 bits, interface SPI |
| Conversor A/D | C2, C3 | 100 nF e 1 µF | Desacoplamento |
| Filtro passa-faixa | R2 | 4,7 kΩ | Largura de banda de cerca de 13,4 kHz |
| Filtro passa-faixa | C4, C5 | 2,2 nF e 330 pF | Em paralelo, totalizando 2,53 nF |
| Filtro passa-faixa | L1 | 1 mH | Centro em cerca de 100 kHz |
| Detector de envelope | D1 | 1N5819 | Diodo Schottky |
| Detector de envelope | C6, R3 | 10 nF e 10 kΩ | Constante de tempo de 100 µs |
| Comparador | U2 | MCP6002 | Alimentado em 3,3 V |
| Comparador | RV1 | Potenciômetro de 10 kΩ | Ajuste do limiar |
| Filtro passa-baixa de saída | R4, C7 | 1 kΩ e 10 µF | Corte em cerca de 16 Hz |

Os valores acima seguem os cálculos do [relatório final](../docs/relatorio-final.pdf).
