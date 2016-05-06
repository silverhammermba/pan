all: report.pdf

report.pdf: report.tex
	pdflatex -interaction nonstopmode $<
	pdflatex -interaction batchmode $<

.deps: comp.gp comp_unrel.gp report.tex
	ruby deps.rb $^ > $@

chart_%.pdf: %.gp
	gnuplot $< > $@

base_%.data: eval_base.rb pan.rb
	ruby $< $*

unrel_%.data omega_unrel_%.gp qdist_unrel_%.gp: eval_unrel.rb pan.rb
	ruby $< $(subst _, ,$*)

exre_%.data omega_exre_%.gp qdist_exre_%.gp exre_dist_%.gp: eval_exre.rb pan.rb
	ruby $< $(subst _, ,$*)

unexre_%.data omega_unexre_%.gp qdist_unexre_%.gp unexre_dist_%.gp: eval_unexre.rb pan.rb
	ruby $< $(subst _, ,$*)

include .deps
