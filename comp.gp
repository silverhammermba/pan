set terminal pdf
set logscale x
set yrange [0:1]
set xlabel 'Attacker'
set ylabel 'P(S|response)'
plot 'base_10.data' with lines title 'Worst case', 'unrel_10_99.data' with lines title 'Unreliable peers', 'exre_10_1.data' with lines title 'Extra responses', 'unexre_10_1_99.data' with lines title 'Both', 0.1 linetype rgb 'black' title 'P(S)'
