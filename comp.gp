set terminal pdf
set logscale x
set yrange [0:1]
set xlabel 'Attacker'
set ylabel 'P(S|response)'
plot 'base_100.data' with lines title 'Worst case',\
'unrel_100_20.data' with lines title 'Unreliable peers',\
'exre_100_1.data' with lines title 'Extra responses',\
'unexre_100_1_20.data' with lines title 'Both',\
0.01 linetype rgb 'black' title 'P(S)'
