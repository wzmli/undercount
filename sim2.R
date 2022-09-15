library(tidyverse)
library(colorblindr)
library(asymptor)

theme_set(theme_bw())
r_exp <- ~ K / (1 + s * exp(-s * r * (t - tinfl)))^(1 / s)

richards_deriv <-  deriv(r_exp, "t",
                         function.arg = c("t", setdiff(all.vars(r_exp), "t")))

richards <- function(..., deriv = FALSE) {
    r <- richards_deriv(...)
    if (!deriv) c(r) else attr(r, "gradient")
}

richards(t = 1, r = 1, tinfl = 4, K=1, s=1, deriv = TRUE)
curve(richards(x, r = 1, tinfl = 4, K=1, s=1), from = 0, to = 10, ylim = c(0,1))
curve(richards(x, r = 1, tinfl = 4, K=1, s=1, deriv = TRUE), from = 0, to = 10)

## solve for I0 as a function of tinfl?
## I0 = K / (1 + s * exp(-s * r * (0 - tinfl)))^(1 / s)
## (1 + s * exp(s*r*tinfl))^(1/s) = K/I0
## (1 + s * exp(s*r*tinfl)) = (K/I0)^s
## exp(s*r*tinfl) = ((K/I0)^s-1)/s
## s*r*tinfl = log(((K/I0)^s-1)/s)
## tinfl = log(((K/I0)^s-1)/s)/(s*r)

i0fun <- function(K, r, s, I0 = 1) {
    log(((K/I0)^s-1)/s)/(s*r)
}

stopifnot(all.equal(1,
                    richards(tinfl = i0fun(K = 1e4, r = 0.02, s = 2),
                             K = 1e4, r = 0.02, s = 2, t = 0)))

stopifnot(all.equal(10,
                    richards(tinfl = i0fun(K = 1e4, r = 0.02, s = 2, I0 = 10),
                             K = 1e4, r = 0.02, s = 2, t = 0)))

rfun <- function(mu, type = "nbinom", k) {
    n <- length(mu)
    if (k == Inf) type <- "poisson"
    switch(type,
           identity = mu,
           nbinom = rnbinom(n, mu = mu, size = k),
           poisson = rpois(n, lambda = mu)
           )
}

##' @param dt time step
##' @param tmax max time
##' @param K max cumulative incidence (final size)
##' @param r growth rate
##' @param a shape parameter
##' @param tinfl inflection point time (epidemic peak)
richards_sim <- function(dt = 1, tmax = 50,
                         K = 10000,
                         r = 0.02,
                         s = 2,
                         I0 = 1,
                         tinfl = NULL,
                         a = 0.6,
                         rtype = "nbinom",
                         obsfun = "binomial",
                         k = 0.5
                         ) {
    if (is.null(tinfl)) tinfl <- i0fun(K = K, r = r, s = s, I0 = I0)
    tvec <- seq(0, tmax, by = dt)
    mu <- richards(t = tvec, r = r, K = K, tinfl = tinfl, s = s)
    (tibble::tibble(date = tvec[-1], mu = diff(mu))
        |> mutate(incidence =  rfun(mu, type = rtype, k = k),
                  cases = if (obsfun == "identity") {a*incidence} else {
                             rbinom(length(date), size = incidence, prob = a)
                                                                },
                  hidden_true = incidence - cases,
                  hidden_biasest = cases^2/dplyr::lag(cases,1),
                  deaths = 0)
    )
}


s1 <- richards_sim()

## We generated data from Poisson and Negative Binomial distributions whose expected value follows a Richards curve, to replicate the epidemic evolution.
## The proposed estimator is a lower bound estimator, based on Chao's lower bound estimator. From the simulations, the proposed estimator plays the role of a lower bound for the true population size whenever the reported cases are a "small" fraction of the true number, in practice if the observed cases are less than 70% of the true total number of cases, as reasonably occurring at the beginning of any epidemic. This is also the reason why we used the estimator only at the beginning of the epidemic, as changing in the testing policy or other external factors may also play a role as long as the epidemic spreads. 

## reasonable params:
params <- (cross_df(list(dt = c(1, 7),  ## daily, weekly
                         r = c(0.01, 0.02, 0.04, 0.08), ## doubling time 70, 35, 17, 8.5 days
                         I0 = c(20, 40),
                         a = c(0.05, 0.1, 0.2, 0.4, 0.6))) 
    |> mutate(tmax = 100, K = 1e5, k = 5, rtype = "identity", obsfun = "identity")
)

set.seed(101)
## \(...) do.call is ugly!
results <- params    |> pmap_df(.id = "sim",  \(...) do.call(richards_sim, list(...)))
ggplot(results, aes(x = date, y = mu, colour = sim)) + geom_line() + scale_y_log10()
ggplot(results, aes(x = date, y = incidence, colour = sim)) + geom_line() + scale_y_log10()

res2 <- params    |> pmap(\(...) do.call(richards_sim, list(...)))

estfun <- function(r) {
    full_join(r,
              with(r, estimate_asympto(date, cases, deaths)),
              by = "date")
}

pfun <- function(d) {
    d2 <- (d |> estfun()
        |> select(-c(deaths))
    )
    d3a <- d2 |> select(-c(lower,upper)) |> pivot_longer(-date)
    d3b <- d2 |> select(c(date,lower,upper))
    ggplot(d3a, aes(x=date, colour = name, y = value)) +
        geom_line() +
        geom_point() +
        geom_ribbon(data = d3b,
                    aes(x = date, ymin = lower, ymax = upper),
                    y = NA,
                    colour = NA,
                    alpha = 0.4) +
        scale_y_log10()
}

pfun(bind_rows(res2, .id = "sim")) + facet_wrap(~sim)

okfun <- function(d) {
    e <- (estfun(d)
        |> filter(cases > 5, cases < 500, lower > 1)  ## removes NAs too
    )
    if (nrow(e) == 0) return(NA_character_)
    below <- with(e, any(hidden_true < lower))
    above <- with(e, any(hidden_true > upper))
    case_when(below && above ~ "both",
              below ~ "below",
              above ~ "above",
              TRUE ~ "OK"
              )
}

results <- bind_cols(params, tibble(result = map_chr(res2, okfun)))

res3 <- (results
    |> select(dt, r, I0, a, result)
    |> mutate(sim = 1:n(),
              across(where(is.numeric), ~ factor(.) |> fct_inorder()))
)

rvec <- unique(results$r)
labs <- sprintf("%1.2f\n(%1.1f)", rvec, log(2)/rvec)

ggplot(res3, aes(r,a, colour = result, shape = result)) +
    geom_point(size=8, alpha = 0.6) +
    geom_text(colour = "black", aes(label = sim)) +
    facet_grid(dt~I0, label = label_both) +
    scale_color_OkabeIto() +
    scale_x_discrete(labels = labs) +
    labs(y = "ascertainment ratio",
         x = "epidemic growth rate/doubling time (per day/days)")

## low ascertainment, high growth rate
pfun(res2[[72]])

