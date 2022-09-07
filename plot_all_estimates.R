library(tidyverse)
library(ggplot2);theme_set(theme_bw(base_size=14))
library(directlabels)
library(cowplot)

library(shellpipes)
rpcall("plot_all_estimates.Rout plot_all_estimates.R low.estimate.rda high.estimate.rda")

startGraphics(width = 8, height = 4)

el <- loadEnvironmentList(trim=".estimate.*")

dat <- el %>% map_dfr("dat", .id = "Scenario")

summary(dat)
summary(dat %>% mutate_if(is.character, as.factor))

summ <- el %>% map_dfr("summ", .id="Scenario")
summary(summ)

c_prop <- el %>% map_dbl("new_c_prop")

hh <- c("high", "low")
replace_scenario <- .  %>% mutate(across(Scenario, factor,
                      levels = hh,
                      labels = sprintf("a = %1.1f", c_prop[hh])))

dat_cum <- (dat
    %>% filter(type != "htfrac")
    %>% mutate(across(type, factor,
                      levels = c("estcuminc", "truecuminc", "cumreport"),
                      labels = c("estimated", "true", "reported")
                      ))
    %>% replace_scenario()
)

gg_cum <- (ggplot(dat_cum, aes(Date,y=value/1e5, color=type, linetype = Scenario))
    + geom_line()
    + ylab("Cumulative count (× 100,000)")
    + theme_bw()
    + theme(legend.position = c(0.2,0.6))
    ## + geom_dl(method = list(dl.trans(x = x + 0.1),
    ## "last.bumpup"),
    ## aes(label = type))
    ## hack to expand limits for direct labels
    ## + expand_limits(x = max(dat$Date) + 60, y = 8)
    + colorblindr::scale_colour_OkabeIto()
)

dat_prop <- (dat
    %>% filter(type == "htfrac")
    %>% replace_scenario()
)

true_prop <- (tibble(Scenario = names(c_prop), value = c_prop)
    %>% replace_scenario())

gg_prop <- (ggplot(dat_prop, aes(Date, value, linetype = Scenario))
    + geom_line()
    + labs(x = "Date", y = "underreporting fraction")
    + geom_hline(data = true_prop,
                 colour = "blue",
                 aes(yintercept = (1-value)/value, linetype = Scenario))
    + theme(legend.position = c(0.2,0.6))
)

plot_grid(gg_cum, gg_prop)

saveVars(gg_cum, gg_prop)

