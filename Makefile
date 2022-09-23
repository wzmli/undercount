## FIXME: Is this obsolete? 2022 Sep 23 (Fri)
## MAKE=/usr/local/opt/make/bin/gmake

current: target
-include target.mk

# -include makestuff/perl.def

all: undercount.pdf sim2.html 

vim_session:
	bash -cl "vmt"

######################################################################

Sources += $(wildcard *.R)

broom.Rout: broom.R

######################################################################

autopipeR = defined

Ignore += undercount.pdf
Sources += undercount.rmd

## also depends on  gg_ok.pdf scaled_bounds.pdf, but we need more
##   workflow magic to make this work
undercount.pdf: undercount.rmd parameters.rda plot_all_estimates.pdf plot_all_estimates.rda
	$(knitpdf)

## FIXME: Is this obsolete? 2022 Sep 23 (Fri)
undercount_short.pdf: undercount_short.rmd a_plot.pdf
	$(knitpdf)

# undercount_short.tex
# undercount_short.tex.Rout: rmd_tex.R undercount_short.rmd
%.tex.Rout: rmd_tex.R %.rmd
	$(pipeR)

# undercount_short.docx.Rout: rmd_docx.R undercount_short.rmd
%.docx.Rout: rmd_docx.R %.rmd
	$(pipeR)

a_plot.Rout: a_plot.R sim_funs.rda
	$(pipeR)

a_plot.Rout.pdf: a_plot.Rout
	pdflatex a_plot.Rout.tikz

sim2.html: sim2.rmd
	$(knithtml)

gg_ok.pdf scaled_bounds.pdf: sim2.html ;

## Stupid work-around for knitr error
Ignore += plot_all_estimates.pdf
%.pdf: %.Rout.pdf
	$(copy)

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

### Makestuff

Sources += Makefile

## Sources += content.mk
## include content.mk

Ignore += makestuff
msrepo = https://github.com/dushoff

Makefile: makestuff/Makefile
makestuff/Makefile:
	git clone $(msrepo)/makestuff
	ls makestuff/Makefile

-include makestuff/os.mk

-include makestuff/pipeR.mk
-include makestuff/rmd.mk
-include makestuff/chains.mk
-include makestuff/git.mk

-include makestuff/visual.mk
