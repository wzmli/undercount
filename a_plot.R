library(tidyverse)
library(colorblindr)
library(asymptor)
library(cowplot)
library(tikzDevice)
theme_set(theme_bw() + theme(panel.spacing = grid::unit(0, "lines")))

library(shellpipes)

rpcall("a_plot.Rout a_plot.R sim_funs.rda")
loadEnvironments()
startGraphics(width = 5.5, height = 5.5
	, otype = "tikz", ext="tikz.tex"
	, standAlone = TRUE
)

params <- (cross_df(list(dt = c(1, 7),  ## daily, weekly
           r = c(0.01, 0.02, 0.04, 0.08), ## doubling time 70, 35, 17, 8.5 days
           I0 = c(20, 40),
           a = c(0.05, 0.1, 0.2, 0.4, 0.6))) 
    |> mutate(tmax = 100, s = 2, K = 1e5, k = 5, rtype = "none", obstype = "none")
)
paramsx <- mutate(params, sim = as.character(1:n()))

set.seed(101)
params_noise <- params |> mutate(rtype = "nbinom", obstype = "binomial")
## FIXME: \(...) do.call is ugly!
res1 <- (params_noise |> pmap(function(...) do.call(richards_sim, list(...))))
res6 <- (res1
    |> map(estfun)
    |> bind_rows(.id = "sim")
    |> full_join(paramsx, by = "sim")
    |> filter(cases > 5, cases < 500, lower > 1)  ## removes NAs too
    |> mutate(across(c(lower, upper), ~ . / cases))
    |> select(sim, date, lower, upper, r, a, I0, dt)
    |> pivot_longer(c(lower, upper))
)
res6_mean <- (res6
    |> group_by(sim, a, r, I0, dt, name)
    |> summarise(across(value, mean, na.rm  = TRUE), .groups = "drop")
)

dodge <- 0.01 ## dodging (manual for geom_segment)
psize <- 0.4  ## point size
lsize <- 0.6  ## linerange size
tsize <- 7    ## x-axis label size
res6_mean <- (res6
    |> group_by(sim, a, r, I0, dt, name)
    |> summarise(across(value, mean_cl_boot), .groups = "drop")
    |> unpack(value)
    |> mutate(across(starts_with("y"), ~ 1/(1+.)))
    |> rename(ymin = "ymax", ymax = "ymin")
    ## manual dodging, position_dodge affects only xend and not x
    |> mutate(a_shift = a + (as.numeric(factor(r)) - 2.5)*dodge)
)
res6_wide <- res6_mean |> select(-c(ymin, ymax)) |> pivot_wider(values_from = y)
## fix_vars <- . %>% rename(`$I_0$` = "I0", `$\\Delta t` = "dt")

## hack strip labels!
my_label <- function (labels, multi_line = TRUE, sep = " = ",
                      subs = c("$I_0$" = "I0", "$\\Delta t$" = "dt"))
{
    value <- label_value(labels, multi_line = multi_line)
    variable <- ggplot2:::label_variable(labels, multi_line = multi_line)
    variable <- lapply(variable,
                       function(x) {
                           for (i in seq_along(subs)) {
                               x[x==subs[[i]]] <- names(subs)[[i]]
                           }
                           x
                       })
    if (multi_line) {
        out <- vector("list", length(value))
        for (i in seq_along(out)) {
            out[[i]] <- paste(variable[[i]], value[[i]], sep = sep)
        }
    }
    else {
        value <- do.call("paste", c(value, sep = ", "))
        variable <- do.call("paste", c(variable, sep = ", "))
        out <- Map(paste, variable, value, sep = sep)
        out <- list(unname(unlist(out)))
    }
    out
}

## alternative OkabeIto palette, skipping colour 4 (yellow, too pale)
alt_OI <- colorblindr::palette_OkabeIto[-4]
r_lab <- "$r$ (growth rate, day$^{-1})$"
## res6_mean |> filter(dt == 7, a >= 0.4, name == "lower")
## pd <- position_dodge(width = 0.01)
a_plot <- (ggplot(res6_mean,
                  aes(x = a_shift, y = y,
                      colour = factor(r), shape = factor(r)))
    + geom_pointrange(size = psize, aes(ymin = ymin, ymax = ymax))
    + geom_linerange(size = lsize, aes(ymin = ymin, ymax = ymax))
    + geom_segment(data = res6_wide,
                   aes(x = a_shift, xend = a_shift,
                       y = lower, yend = upper), alpha = 0.3, size = 0.5)
    + geom_abline(intercept = 0, slope = 1, lty = 2)
    + scale_colour_manual(values = alt_OI, name = r_lab)
    + scale_shape_manual(name = r_lab, values = 15:18)
    + labs (x = "true ascertainment ratio ($a$)", y = "estimated ascertainment ratio bounds ($\\hat a$)")
    + expand_limits(y = c(0.05, 0.6))
    + scale_x_continuous(breaks = c(0.05, 0.1, 0.2, 0.4, 0.6))
    + facet_wrap(I0 ~ dt, labeller = my_label)
    + scale_y_continuous() ##limits = c(0.05, 0.6), oob = scales::squish)
    + theme(legend.position = "bottom",
            axis.text.x = element_text(size = tsize) ## avoid label collisions
            )
)

print(a_plot)
