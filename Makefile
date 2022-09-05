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
	$(pipeR)

states.Rout: states.R parameters.rda
	$(pipeR)

model_definition.Rout: model_definition.R parameters.rda states.rda
	$(pipeR)

simulate.Rout: simulate.R model_definition.rda
	$(pipeR)

est_cuminf.Rout: est_cuminf.R simulate.rda parameters.rda
	$(pipeR)

plot_cuminf.Rout: plot_cuminf.R est_cuminf.rda parameters.rda
	$(pipeR)

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
