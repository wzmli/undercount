library(ggplot2);theme_set(theme_bw(base_size=14))
library(directlabels)
library(shellpipes)
library(tidyverse)
library(cowplot)

## rpcall("plot_cuminf.Rout plot_cuminf.R est_cuminf.rda parameters.rda")
loadEnvironments()
startGraphics(width = 8, height = 4)

dat_cum <- (dat
    %>% filter(type != "htfrac")
    %>% mutate(across(type, factor,
                      levels = c("cumreport", "truecuminc",
                                 "estcuminc"),
                      labels = c("reported\ncases",
                                 "true\ncases",
                                 "estimated\ncases")
                      ))
)

gg_cum <- (ggplot(dat_cum, aes(Date,y=value,color=type))
    + geom_line()
    + ylab("Cumulative Count")
    + theme_bw()
    + theme(legend.position = "none")
    + geom_dl(method = list(dl.trans(x = x + 0.1),
                            "last.bumpup"),
              aes(label = type))
    ## hack to expand limits for direct labels
    + expand_limits(x = max(dat$Date) + 60, y = max(dat$value*1.2))
    + scale_colour_brewer(palette = "Dark2")
)

dat_prop <- filter(dat, type == "htfrac")
gg_prop <- (ggplot(dat_prop, aes(Date, value))
    + geom_line()
    + labs(x = "Date", y = "underreporting fraction")
    + geom_hline(yintercept = (1-c_prop)/c_prop, lty = 2)
)

plot_grid(gg_cum, gg_prop)
