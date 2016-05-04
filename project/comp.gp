set terminal pdf
set logscale x
set xlabel 'Peer'
set ylabel 'P(S|response)'
plot 'base.data' with lines title 'Worst case', 'unrel.data' with lines title 'Unreliable peers', 'exre.data' with lines title 'Extra responses', 'unexre.data' with lines title 'Both'
