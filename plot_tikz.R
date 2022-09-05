library(ggplot2);theme_set(theme_bw(base_size=14))
library(directlabels)
library(cowplot)
library(shellpipes)
library(tikzDevice)
rpcall("plot_cuminf.rda")
loadEnvironments()
## startGraphics(width = 8, height = 4, otype = "tikz", ext = ".tex")

tikz("plot_cuminf.tex", standAlone = TRUE, width = 8, height = 4)
plot_grid(gg_cum, gg_prop)
dev.off()

