set terminal pdf
set logscale x
set yrange [0:1]
set xlabel 'Attacker'
set ylabel 'P(S|response)'
plot 'base_100.data' with lines title 'Worst case',\
'unrel_100_80.data' with lines title 'r=0.8',\
'unrel_100_60.data' with lines title 'r=0.6',\
'unrel_100_40.data' with lines title 'r=0.4',\
'unrel_100_20.data' with lines title 'r=0.2',\
'unrel_100_1.data' with lines title 'r=0.01',\
0.01 linetype rgb 'black' title 'P(S)'
