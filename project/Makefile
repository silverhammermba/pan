all: report.pdf

%.pdf: %.tex
	pdflatex -interaction nonstopmode $^
	pdflatex $^

report.pdf: qdist3d.pdf qdist3d_final.pdf qdist3d_er.pdf qdist3d_er_final.pdf qdist3d_uer.pdf qdist3d_uer_final.pdf comp.pdf exre_dist.pdf unexre_dist.pdf

qdist%.pdf: qdist%.gp
	gnuplot $< > $@

%_dist.pdf: %_dist.gp
	gnuplot $< > $@

comp.pdf: comp.gp base_100.data unrel_100_25.data exre_100_1.data unexre_100_1_25.data
	gnuplot $< > $@

comp_unrel.pdf: comp_unrel.gp base_100.data unrel_100_99.data unrel_100_75.data unrel_100_50.data unrel_100_25.data unrel_100_1.data
	gnuplot $< > $@

base_%.data: eval_base.rb pan.rb
	ruby $< $*

unrel_%.data: eval_unrel.rb pan.rb
	ruby $< $(subst _, ,$*)

exre_%.data: eval_exre.rb pan.rb
	ruby $< $(subst _, ,$*)

unexre_%.data: eval_unexre.rb pan.rb
	ruby $< $(subst _, ,$*)
