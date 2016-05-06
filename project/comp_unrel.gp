set terminal pdf
set logscale x
set yrange [0:1]
set xlabel 'Attacker'
set ylabel 'P(S|response)'
plot 'base_10.data' with lines title 'Worst case', 'unrel_10_99.data' with lines title 'r=0.99', 'unrel_10_75.data' with lines title 'r=0.75', 'unrel_10_50.data' with lines title 'r=0.50', 'unrel_10_25.data' with lines title 'r=0.25', 'unrel_10_1.data' with lines title 'r=0.01', 0.1 linetype rgb 'black' title 'P(S)'
