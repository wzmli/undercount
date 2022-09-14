##' @param K max cumulative incidence
##' @param r growth rate
##' @param a shape parameter
##' @param tinfl inflection point time

r_exp <- ~ K / (1 + a * exp(-a * r * (t - tinfl)))^(1 / a)
richards_deriv <-  deriv(r_exp, "t",
                         function.arg = c("t", setdiff(all.vars(r_exp), "t")))

richards <- function(..., deriv = FALSE) {
    r <- richards_deriv(...)
    if (!deriv) c(r) else attr(r, "gradient")
}

richards(t = 1, r = 1, tinfl = 4, K=1, a=1, deriv = TRUE)
curve(richards(x, r = 1, tinfl = 4, K=1, a=1), from = 0, to = 10, ylim = c(0,1))
curve(richards(x, r = 1, tinfl = 4, K=1, a=1, deriv = TRUE), from = 0, to = 10)

##' @param
richards_sim <- function(dt = 1, tmax = 50,
                         K = 10000,
                         a = 2)
                         
