## undercount

This repository contains a reponse to several papers by Maruotti, Böhning et al, which propose a flawed method for estimating undercounting (also known as the *ascertainment ratio*) from case reports of epidemic disease.

- We have submitted a letter to the editor (see `undercount_short.rmd`, `outputs/undercount_short.pdf`) to *J. Med. Virology* and posted a preprint on [arxiv](https://t.co/ki3OoysqNb).
- `undercount.rmd` contains earlier work (much of which was cut from the letter to the editor to satisfy word-count requirements), including an SIR-based example and some algebra evaluating a version of Maruotti *et al.*'s lower-bound criterion for the exponential phase of an epidemic.

## code and source files

The workflow uses the `make` utility, [makestuff](https://github.com/dushoff/makestuff) rules, and the [shellpipes](https://github.com/dushoff/shellpipes) R package
- install packages: `make pkgs` or run `install_packages.R`
    - Required R packages: (GitHub) `dushoff/shellpipes`, `mac-theobio/McMasterPandemic` , `clauswilke/colorblindr`, (CRAN) `cowplot`, `tidyverse`, `directlabels`, `tikzDevice`, `asymptor`, `rticles`
- `make` targets: `undercount_short.pdf`, `undercount.pdf`, `sim2.html`
- `states.R`, `low.R`, `high.R`, `parameters.R`, `model_definition.R`, `simulate.R`, `plot_all_estimates.R`: workflow for SIR model simulations and plots using [McMasterPandemic](https://github.com/mac-theobio/McMasterPandemic)
- `sim2.rmd`: various views of Richards-model simulations
- `a_plot.R`: Richards-model simulations and plot for short letter
- **junk/obsolete**: `plot_tikz.R`

## References

- Böhning, Dankmar, Irene Rocchetti, Antonello Maruotti, and Heinz Holling. “Estimating the Undetected Infections in the Covid-19 Outbreak by Harnessing Capture–Recapture Methods.” International Journal of Infectious Diseases 97 (August 2020): 197–201. https://doi.org/10.1016/j.ijid.2020.06.009.
- Maruotti, Antonello, Dankmar Böhning, Irene Rocchetti, and Massimo Ciccozzi. “Estimating the Undetected Infections in the Monkeypox Outbreak.” Journal of Medical Virology n/a, no. n/a (2022). https://doi.org/10.1002/jmv.28099.
- Rocchetti, Irene, Dankmar Böhning, Heinz Holling, and Antonello Maruotti. “Estimating the Size of Undetected Cases of the COVID-19 Outbreak in Europe: An Upper Bound Estimator.” Epidemiologic Methods 9, no. s1 (May 1, 2020). https://doi.org/10.1515/em-2020-0024.
