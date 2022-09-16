cran_pkgs <- c("cowplot", "directlabels", "ggplot2", "tikzDevice","remotes", "asymptor")

github_pkgs <- c("dushoff/shellpipes", "mac-theobio/McMasterPandemic")

i1 <- installed.packages()
cran_pkgs <- setdiff(cran_pkgs, rownames(i1))

if (length(cran_pkgs)>0) install.packages(cran_pkgs)
sapply(github_pkgs, remotes::install_github)

