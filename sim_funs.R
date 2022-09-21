library(shellpipes)
library(tibble)
library(dplyr)

## define Richards equation as an expression
r_exp <- ~ K / (1 + s * exp(-s * r * (t - tinfl)))^(1 / s)

## make it into a function returning value and gradient
richards_deriv <-  deriv(r_exp, "t",
                         function.arg = c("t", setdiff(all.vars(r_exp), "t")))

## wrap to return value *or* gradient
richards <- function(..., deriv = FALSE) {
    dd <- richards_deriv(...)
    r <- if (!deriv) dd else attr(dd, "gradient")
    ## get rid of everything: names, attributes, dimensions, ...
    c(unname(drop(r)))
}

## check
stopifnot(all.equal(
    richards(t = 1, r = 1, tinfl = 4, K=1, s=1),
    0.0474258731775668))
                    
## curve(richards(x, r = 1, tinfl = 4, K=1, s=1), from = 0, to = 10, ylim = c(0,1))
## curve(richards(x, r = 1, tinfl = 4, K=1, s=1, deriv = TRUE), from = 0, to = 10)

## solve for I0 as a function of tinfl
## I0 = K / (1 + s * exp(-s * r * (0 - tinfl)))^(1 / s)
## (1 + s * exp(s*r*tinfl))^(1/s) = K/I0
## (1 + s * exp(s*r*tinfl)) = (K/I0)^s
## exp(s*r*tinfl) = ((K/I0)^s-1)/s
## s*r*tinfl = log(((K/I0)^s-1)/s)
## tinfl = log(((K/I0)^s-1)/s)/(s*r)

## deriv calculation
## sympy:
## from sympy import *
## ti, t, r, x, i0, K, s = symbols("ti, t, r,x,i0,K,s")
## richards = K/(1+s*exp(-s*r*(t-ti)))**(1/s)
## simplify(diff(richards, t).subs(t,0))
## K*r*s*exp(r*s*ti)/(s*exp(r*s*ti) + 1)**((s + 1)/s)

## K*r*s*exp(r*s*ti)/(s*exp(r*s*ti) + 1)**((s + 1)/s) == i0
## log(i0) = log(K*r*s) + r*s*ti - ((s+1)/s)*(log(s) + r*s*ti)
## log(i0) - log(K*r*s) =  r*s*ti - ((s+1)/s)*(log(s) + r*s*ti)
## log(i0) - log(K*r*s) + ((s+1)/s)*log(s) =  r*s*ti * (1 - ((s+1)/s))
## ti = (log(i0) - log(K*r*s) + ((s+1)/s)*log(s))/(r*s*(1-1/s)


i0fun <- function(K, r, s, I0 = 1) {
    ## deriv at zero, -1
    f <- function(ti) { K*r*s*exp(r*s*ti)/(s*exp(r*s*ti) + 1)**((s + 1)/s) - I0}
    uniroot(f , c(1e-3, 1000))$root
}

## check
tinfl <- i0fun(K = 1e4, r = 0.02, s = 2)
stopifnot(all.equal(1,
                    richards(tinfl = tinfl, K = 1e4, r = 0.02, s = 2, t = 0, deriv = TRUE)
                    )
          )

## old: set initial **cumulative incidence** to i0
## i0fun <- function(K, r, s, I0 = 1) {
##     log(((K/I0)^s-1)/s)/(s*r)
## }

## noise wrapper
rfun <- function(mu, type = "nbinom", k) {
    n <- length(mu)
    if (k == Inf) type <- "poisson"
    switch(type,
           none = mu,
           nbinom = rnbinom(n, mu = mu, size = k),
           poisson = rpois(n, lambda = mu)
           )
}

##' Simulate incidence etc. based on a cumulative Richards curve
##' @param dt time step
##' @param tmax max time
##' @param K max cumulative incidence (final size)
##' @param r growth rate
##' @param s shape parameter
##' @param tinfl inflection point time (epidemic peak; computed from I0 by default)
##' @param I0 initial incidence 
##' @param a ascertainment ratio
##' @param rtype randomness for incidence
##' @param obstype randomness for reporting
##' @param k dispersion parameter for negative binomial
##' @return a tibble containing date, incidence (not cumulative!), cases, true number of hidden cases, number of hidden cases computed by simple (biased) formula, deaths (currently set to zero)
richards_sim <- function(dt = 1, tmax = 50,
                         K = 10000,
                         r = 0.02,
                         s = 2,
                         I0 = 1,
                         tinfl = NULL,
                         a = 0.6,
                         rtype = c("nbinom", "poisson", "none"),
                         obstype = c("binomial","none"),
                         k = 0.5
                         ) {
    rtype <- match.arg(rtype)
    obstype <- match.arg(obstype)
    if (is.null(tinfl)) tinfl <- i0fun(K = K, r = r, s = s, I0 = I0)
    tvec <- seq(0, tmax, by = dt)
    mu <- richards(t = tvec, r = r, K = K, tinfl = tinfl, s = s)
    ## compute differences etc.
    (tibble::tibble(date = tvec[-1], mu = diff(mu))
        |> dplyr::mutate(incidence =  rfun(mu, type = rtype, k = k),
                  cases = if (obstype == "none") {a*incidence} else {
                             rbinom(length(date), size = incidence, prob = a)
                                                                },
                  hidden_true = incidence - cases,
                  ## hidden_biasest = cases^2/dplyr::lag(cases,1),
                  deaths = 0  ## needed for asymptor
                  )
    )
}

## estimation
estfun <- function(r) {
    dplyr::full_join(r,
              with(r, estimate_asympto(date, cases, deaths)),
               by = "date")
}

saveEnvironment()

