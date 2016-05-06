set terminal pdf
set logscale x
set xlabel 'Peer'
set ylabel 'P(S|response)'
plot 'base_10.data' with lines title 'Worst case', 'unrel_10_50.data' with lines title 'Unreliable peers', 'exre_10_1.data' with lines title 'Extra responses', 'unexre_10_1_50.data' with lines title 'Both'
