## hard-code CRAN repos to avoid --vanilla/non-interactive problems
repos <- c(CRAN = "https://cloud.r-project.org")
options(repos = repos)

cran_pkgs <- c("cowplot", "directlabels", "ggplot2", "tikzDevice","remotes", "asymptor", "rticles")

github_pkgs <- c("dushoff/shellpipes", "mac-theobio/McMasterPandemic", "clauswilke/colorblindr")

i1 <- installed.packages()
cran_pkgs <- setdiff(cran_pkgs, rownames(i1))
if (length(cran_pkgs)>0) install.packages(cran_pkgs)

## MacPan seems to be problematic -- too big?
sapply(github_pkgs, function(x) try(remotes::install_github(x)))

