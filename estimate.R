library(McMasterPandemic)
library(tidyverse)
library(shellpipes)
library(asymptor)
rpcall("low.estimate.Rout estimate.R low.simulate.rda low.rda")
rpcall("high.estimate.Rout estimate.R high.simulate.rda high.rda")
loadEnvironments()

## 

## htfun <- function(n){
## 	n_1 <- dplyr::lag(n, 1)
##         return((n*(n-1))/(1+n_1))
## }

print(head(simdat))

dat0 <- (simdat
    |> transmute(NULL
               , date = Date
               , incidence
               , cases = reportProp*incidence
               , hidden = (1-reportProp)*incidence
               , deaths = 0)
)
dat1 <- (dat0
    |> select(-c(incidence, hidden))
    |> do.call(what = estimate_asympto)
)
dat_wide <- (full_join(dat0,
                  dat1,
                  by = "date")
    |> select(-deaths)
    |> mutate(asc_lower = cases/(cases + lower),
              asc_upper = cases/(cases + upper))
)

dat_long <- (dat_wide
    |> pivot_longer(-date, names_to = "type", values_to = "value")
)

print(dat_long)

summ <- with(dat_wide,
             c(min = min(asc_lower, na.rm = TRUE)
             , max = max(asc_lower, na.rm = TRUE)
             , mean = mean(asc_lower, na.rm  = TRUE)
             , reportProp=reportProp)
             )

print(summ)

saveVars(dat_wide, dat_long, summ, reportProp)
