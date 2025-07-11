## This is the monkeypox-inspired response to a undercount paper

current: target
-include target.mk

-include makestuff/perl.def

all = undercount_jmv.pdf
all: $(all)

vim_session:
	bash -cl "vmt"

######################################################################

Sources += README.md responses.md responses2.md TODO.md

responses.html: responses.md
	$(ghh_r)

responses2.html: responses2.md
	$(ghh_r)

######################################################################

Sources += $(wildcard *.R *.rmd *.pl)

autopipeR = defined

Ignore += undercount_long.pdf

## Does this comment still apply? FIXME 2022 Sep 29 (Thu)
## also depends on  gg_ok.pdf scaled_bounds.pdf, but we need more
##   workflow magic to make this work
undercount_long.pdf: undercount_long.rmd parameters.rda plot_all_estimates.pdf plot_all_estimates.rda a_plot.pdf
	$(rmdpdf)

plot_all_estimates.pdf: plot_all_estimates.Rout.pdf
	$(copy)

######################################################################

## Shorter versions (current; on arxiv, and submitted)

Ignore += $(wildcard *.tex)

responses.pdf: responses.md
	$(render)

responses2.pdf: responses2.md
	$(render)

## undercount_short.pdf: undercount_short.rmd
undercount_short.tex undercount_base.tex: %.tex: %.rmd a_plot.pdf
	$(render)
	$(readonly)

## Put author information into this file to have perl insert it after rendering
Sources += authors.inc
## undercount_jmv.pdf: undercount_short.rmd
undercount_jmv.tex: undercount_short.tex authors.inc fixtex.pl undercount.bib
	$(PUSH)

######################################################################

## This is ugly, and doesn't contain author information, but the best I was able to do

Ignore += *.docx
undercount_short.docx: undercount_short.rmd
	$(render)

######################################################################

## diff machinery

compare_sept_sub: undercount_short.rmd.9843e02.oldfile
second_sub: undercount_short.rmd.d9ab52e0.oldfile

## Untested (dependency was chaining badly) 2023 Jan 04 (Wed)
## undercount_diff.pdf: undercount_short.rmd
undercount_base.rmd:
	$(CP) undercount_short.rmd.*.oldfile $@

undercount.ld.tex: undercount_base.tex undercount_short.tex
	$(latexdiff)

undercount_diff.tex: undercount.ld.tex authors.inc fixtex.pl undercount.bib
	$(PUSH)

######################################################################

## a_plot.pdf: a_plot.R
a_plot.Rout: a_plot.R sim_funs.rda
	$(pipeR)

a_plot.Rout.tikz.tex: a_plot.Rout ;

## Stupid work-around for knitr incompatibility
Ignore += plot_all_estimates.pdf
%.pdf: %.Rout.tikz.pdf
	$(copy)

######################################################################

## What is this (used to conflict with a_plot)?
another_plot.pdf: sim2.html ;

sim2.html: sim2.rmd
	$(knithtml)

gg_ok.pdf scaled_bounds.pdf: sim2.html ;

parameters.Rout: parameters.R
	$(pipeR)

states.Rout: states.R parameters.rda
	$(pipeR)

model_definition.Rout: model_definition.R parameters.rda states.rda
	$(pipeR)

sim_funs.Rout: sim_funs.R
	$(pipeR)

## packages
pkgs:
	Rscript install_pkgs.R

## Setting up different parameters

ascScen = low high
estScen = $(ascScen:%=%.estimate.rda)
$(estScen): %.rda: %.Rout ; $(lscheck)

high.Rout: high.R
	$(pipeR)

medium.Rout: medium.R
	$(pipeR)

low.Rout: low.R
	$(pipeR)

impmakeR += simulate

# high.simulate.Rout: simulate.R model_definition.R
%.simulate.Rout: simulate.R model_definition.rda %.rda
	$(pipeR)

impmakeR += estimate

# high.estimate.Rout: estimate.R
%.estimate.Rout: estimate.R %.simulate.rda %.rda
	$(pipeR)

impmakeR += plot_estimate
# high.plot_estimate.Rout: plot_estimate.R
%.plot_estimate.Rout: plot_estimate.R %.estimate.rda parameters.rda
	$(pipeR)

plot_tikz.Rout: plot_estimate.rda
	$(pipeR)

plot_all_estimates.Rout: plot_all_estimates.R
plot_all_estimates.Rout: $(estScen)

plot_all.Rout: high.estimate

######################################################################

## Make pdf from Auto tex files the simple way!
a_plot.Rout.tikz.pdf: a_plot.Rout.tikz.tex
%.pdf: %.tex
	pdflatex $<

######################################################################

### Makestuff

Sources += Makefile

## Sources += content.mk
## include content.mk

Ignore += makestuff
msrepo = https://github.com/dushoff

Makefile: makestuff/undercount03.stamp
makestuff/%.stamp:
	- $(RM) makestuff/*.stamp
	(cd makestuff && $(MAKE) pull) || git clone $(msrepo)/makestuff
	touch $@

-include makestuff/os.mk

-include makestuff/pipeR.mk
-include makestuff/rmd.mk
-include makestuff/pandoc.mk
-include makestuff/chains.mk
-include makestuff/git.mk

-include makestuff/visual.mk
