library(tidyverse)
library(colorblindr)
library(asymptor)
library(cowplot)
theme_set(theme_bw() + theme(panel.spacing = grid::unit(0, "lines")))

library(shellpipes)

loadEnvironments()
startGraphics(width = 5.5, height = 5.5)

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

dodge <- 0.01
psize <- 0.4
lsize <- 0.6
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
    + scale_colour_OkabeIto(name = "r\n(growth rate, /day)")
    + scale_shape_manual(name = "r\n(growth rate, /day)", values = 15:18)
    + labs (x = "true ascertainment ratio", y = "estimated ascertainment ratio bounds")
    + expand_limits(y = c(0.05, 0.6))
    + scale_x_continuous(breaks = c(0.05, 0.1, 0.2, 0.4, 0.6))
    + facet_wrap(I0 ~ dt, labeller = label_both)
    + scale_y_continuous() ##limits = c(0.05, 0.6), oob = scales::squish)
    + theme(legend.position = "bottom",
            axis.text.x = element_text(size = 6) ## avoid label collisions
            )
)

print(a_plot)
