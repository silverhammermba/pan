all: report.pdf

report.pdf: report.tex
	pdflatex -interaction nonstopmode $<
	pdflatex $<

.deps: comp.gp comp_unrel.gp report.tex
	ruby deps.rb $^ > $@

chart_%.pdf: %.gp
	gnuplot $< > $@

base_%.data: eval_base.rb pan.rb
	ruby $< $*

unrel_%.data: eval_unrel.rb pan.rb
	ruby $< $(subst _, ,$*)

exre_%.data exre_dist_%.gp: eval_exre.rb pan.rb
	ruby $< $(subst _, ,$*)

unexre_%.data unexre_dist_%.gp: eval_unexre.rb pan.rb
	ruby $< $(subst _, ,$*)

include .deps
