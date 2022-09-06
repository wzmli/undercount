current: target
-include target.mk

# -include makestuff/perl.def

all: undercount.pdf

vim_session:
	bash -cl "vmt"

######################################################################

Sources += $(wildcard *.R)

######################################################################

autopipeR = defined

Ignore += undercount.pdf
Sources += undercount.rmd
undercount.pdf: undercount.rmd parameters.rda plot_all_estimates.pdf
	$(knitpdf)

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


## Setting up different parameters

ascScen = low medium high
estScen = $(ascScen:%=%.estimate.rda)

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
-include makestuff/chains.mk
-include makestuff/git.mk
-include makestuff/visual.mk
