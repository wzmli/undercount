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
undercount.pdf: undercount.rmd parameters.rda plot_cuminf.Rout.pdf
	Rscript -e "rmarkdown::render('undercount.rmd')"

parameters.Rout: parameters.R
	$(pipeRcall)

states.Rout: states.R parameters.rda
	$(pipeRcall)

model_definition.Rout: model_definition.R parameters.rda states.rda
	$(pipeRcall)

simulate.Rout: simulate.R model_definition.rda
	$(pipeRcall)

est_cuminf.Rout: est_cuminf.R simulate.rda parameters.rda
	$(pipeRcall)

plot_cuminf.Rout: plot_cuminf.R est_cuminf.rda parameters.rda
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
