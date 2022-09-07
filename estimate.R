library(McMasterPandemic)
library(tidyverse)
library(shellpipes)
rpcall("low.estimate.Rout estimate.R low.simulate.rda low.rda")
rpcall("high.estimate.Rout estimate.R high.simulate.rda high.rda")
loadEnvironments()

## 

htfun <- function(n){
	n_1 <- dplyr::lag(n, 1)
        return((n*(n-1))/(1+n_1))
}


print(head(simdat))

dat0 <- (simdat
    %>% mutate(NULL
		, truecuminc = cumsum(incidence)
      , report = new_c_prop*incidence 
      , ht = htfun(report)
      , cumreport = cumsum(report)
      , htfill = ifelse(is.na(ht),0,ht)
        ## ratio of estimated hidden to observed
      , htfrac = ht/report
        ## ratio of estimated hidden to true missed cases
      , htcorr = ht/(incidence-report)
      , cumht = cumsum(htfill)
      , estcuminc = cumreport+cumht
	)
    %>% filter(report > 1)
)

dat1 <- (dat0
   %>% select(Date, cumreport, truecuminc, estcuminc, htfrac)
)

dat <- (dat1
    %>% pivot_longer(!Date, names_to = "type", values_to = "value")
)

print(dat)

summ <- with(dat0,
             c(min = min(htfrac, na.rm = TRUE),
               max = max(htfrac, na.rm = TRUE),
               mean = mean(htfrac, na.rm  = TRUE))
             )

saveVars(dat, summ, new_c_prop)
