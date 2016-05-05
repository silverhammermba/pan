set terminal pdf
set logscale x
set xlabel 'Peer'
set ylabel 'P(S|response)'
plot 'base_100.data' with lines title 'Worst case', 'unrel_100_25.data' with lines title 'Unreliable peers', 'exre_100_1.data' with lines title 'Extra responses', 'unexre_100_1_25.data' with lines title 'Both'
