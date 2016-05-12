# Attribution Privacy #

This is my research on attribution privacy, which I did for my final project in
CSE450 Privacy Aware Data Analytics. tl;dr attribution privacy is when you have
a P2P network where some peers are the original sources of the data, and they
want to keep that private (they don't want the data to be *attributed* to them).

## Building ##

If you have pdflatex, ruby, and gnuplot you should be able to just type `make`
to build `report.pdf`. This generates all the data for the paper by running
thousands of network simulations, so you need a pretty fast system and a good
bit of RAM if you don't want it to take forever.

You can speed it up if you make the simulated networks smaller. They all use 100
peers currently, but you can change that by changing the `*.data` files use in
the `*.gp` plot files, and by changing the `chart*.pdf` inclusions in
`report.tex`. The Makefile has rules for running the correct network simulations
based on these file names.
