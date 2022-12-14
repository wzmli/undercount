library(tidyverse)
library(ggplot2); theme_set(theme_bw(base_size=14))
library(directlabels)
library(cowplot)
library(colorblindr)

library(shellpipes)
rpcall("plot_all_estimates.Rout plot_all_estimates.R low.estimate.rda high.estimate.rda")

startGraphics(width = 8, height = 4)

my_lwd <- 1.5
alpha_region <- 0.3

el <- loadEnvironmentList(trim=".estimate.*")

dat_long <- el %>% map_dfr("dat_long", .id = "Scenario")
dat_wide <- el %>% map_dfr("dat_wide", .id = "Scenario")

summary(dat_long %>% mutate_if(is.character, as.factor))

summ <- el %>% map_dfr("summ", .id="Scenario")
summary(summ)

rProp <- el %>% map_dbl("reportProp")

hh <- c("high", "low")
replace_scenario <- .  %>% mutate(across(Scenario, factor,
                      levels = hh,
                      labels = sprintf("a = %1.1f", rProp[hh])))

## we need a variety of shapes to conveniently do all the plots
pdat <- (dat_wide
    |> filter(cases>1)
)

## data for hidden cases
pdat1 <- (pdat
    |> select(c(Scenario, date, lower, upper, true = hidden, cases, incidence))
    |> replace_scenario()
)

print(pdat1)


gg0 <- (ggplot(pdat1, aes(date)) +
 geom_ribbon(aes(ymin = lower, ymax = upper, fill = Scenario), colour = NA,
             alpha = alpha_region)
    + scale_colour_OkabeIto()
    + scale_fill_OkabeIto()
)

gg_hidden <- (gg0 
#	 + geom_line(aes(y=incidence),color="black")
    + geom_line(aes(colour = Scenario, y = true))
#	 + geom_line(aes(colour = Scenario, y = cases),linetype = "dashed",size=1.5)
    + labs (y = "hidden cases")
    + theme(legend.position = "none")
    + scale_y_log10(limits = c(1, NA))
)

## data for ascertainment ratios
pdat2 <- (pdat
    |> select(c(Scenario, date, asc_lower, asc_upper))
    |> rename(lower = "asc_lower", upper = "asc_upper")
    |> replace_scenario()
)

gg_asc <- (gg0 %+% pdat2
    + geom_hline(data = summ |> replace_scenario(),
                 aes(yintercept = reportProp, colour = Scenario))
    + labs(y = "ascertainment ratio")
)

plot_grid(gg_hidden, gg_asc, rel_widths = c(0.45, 0.55))

saveVars(gg_hidden, gg_asc, summ)

