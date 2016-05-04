all: report.pdf

%.pdf: %.tex
	pdflatex $^
	pdflatex $^

report.pdf: qdist3d.pdf qdist3d_final.pdf qdist3d_er.pdf qdist3d_er_final.pdf qdist3d_uer.pdf qdist3d_uer_final.pdf comp.pdf exre_dist.pdf unexre_dist.pdf

qdist%.pdf: qdist%.gp
	gnuplot $^ > $@
