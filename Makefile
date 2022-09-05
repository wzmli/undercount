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
undercount.pdf: undercount.rmd parameters.rda est_cuminf.rda plot_cuminf.Rout.pdf
	$(knitpdf)

parameters.Rout: parameters.R
	$(pipeRcall)

states.Rout: states.R parameters.rda
	$(pipeRcall)

model_definition.Rout: model_definition.R parameters.rda states.rda
	$(pipeRcall)


## Setting up different parameters

high.Rout: high.R
	$(pipeRcall)

med.Rout: med.R
	$(pipeRcall)

low.Rout: low.R
	$(pipeRcall)

impmakeR += simulate


# high.simulate.Rout: simulate.R model_definition.R
%.simulate.Rout: simulate.R model_definition.rda %.rda
	$(pipeRcall)

impmakeR += est_cuminf

# high.est_cuminf.Rout: est_cuminf.R
%.est_cuminf.Rout: est_cuminf.R %.simulate.rda %.rda
	$(pipeRcall)


impmakeR += plot_cuminf

# high.plot_cuminf.Rout: plot_cuminf.R
%.plot_cuminf.Rout: plot_cuminf.R %.est_cuminf.rda parameters.rda
	$(pipeRcall)


plot_tikz.Rout: plot_cuminf.rda
	$(pipeRcall)

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
