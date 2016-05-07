set terminal pdf
set logscale x
set yrange [0:1]
set xlabel 'Attacker'
set ylabel 'P(S|response)'
plot 'base_100.data' with lines title 'Worst case',\
'unrel_100_99.data' with lines title 'r=0.99',\
'unrel_100_75.data' with lines title 'r=0.75',\
'unrel_100_50.data' with lines title 'r=0.50',\
'unrel_100_25.data' with lines title 'r=0.25',\
'unrel_100_1.data' with lines title 'r=0.01',\
0.01 linetype rgb 'black' title 'P(S)'
