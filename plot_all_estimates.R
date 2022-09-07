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

ddtrue <- (dat_cum
	%>% filter(type == "true")
	%>% mutate(type = as.character(type))
)

print(ddtrue)

dat_cum2 <- (dat_cum
	%>% filter(type != "true")
	%>% mutate(type = factor(type,levels=c("estimated","reported"))
	)
)

print(dat_cum2)

#gg_cum <- (ggplot(dat_cum, aes(Date,y=value/1e5, color=type, linetype = Scenario))
gg_cum <- (ggplot(dat_cum2, aes(Date,y=value/1e5))
	 + geom_line(aes(color=Scenario,linetype=type))
	 + scale_linetype_manual(values=c("dashed","solid"))
    + ylab("Cumulative count (× 100,000)")
    + theme_bw()
    + theme(legend.position = c(0.2,0.6))
	 + xlim(as.Date(c("2022-01-01","2022-07-01")))
    ## + geom_dl(method = list(dl.trans(x = x + 0.1),
    ## "last.bumpup"),
    ## aes(label = type))
    ## hack to expand limits for direct labels
    ## + expand_limits(x = max(dat$Date) + 60, y = 8)
    + colorblindr::scale_colour_OkabeIto()
    + geom_line(data=ddtrue,aes(Date,y=value/1e5),
                size=1.5,color="black")
    + annotate(geom = "text", x = max(dat_cum2$Date)-50,
               y = 5, label = "incidence")
)

dat_prop <- (dat
    %>% filter(type == "htfrac")
    %>% replace_scenario()
)

true_prop <- (tibble(Scenario = names(c_prop), value = c_prop)
    %>% replace_scenario())

## FIXME: better to merge, make horizontal lines pseudo-data
gg_prop <- (ggplot(dat_prop, aes(Date, value, color = Scenario))
    + geom_line(linetype = "dashed")
    + labs(x = "Date", y = "underreporting ratio")
    + geom_hline(data = true_prop,
    #             colour = "blue",
                 aes(yintercept = (1-value)/value, color = Scenario))
    + theme(legend.position = c(0.2,0.6))
    + colorblindr::scale_colour_OkabeIto()
)

plot_grid(gg_cum, gg_prop)

saveVars(gg_cum, gg_prop, summ)

