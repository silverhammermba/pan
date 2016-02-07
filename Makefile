TEX=$(wildcard *.tex)
PDF=$(TEX:.tex=.pdf)

default: $(PDF)

.PHONY: clean

%.pdf: %.tex
	pdflatex $<

clean:
	rm -rf *.aux *.log
