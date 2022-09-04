library(McMasterPandemic)
library(tidyverse)
library(shellpipes)
## rpcall("est_cuminf.Rout est_cuminf.R simulate.rda")
loadEnvironments()

## 

htfun <- function(n){
	n_1 <- dplyr::lag(n, 1)
        return((n*(n-1))/(1+n_1))
}


simdat <- (simdat
    %>% filter(I > I0)
    %>% mutate(ht = htfun(conv_incidence))
)

print(head(simdat))

dat <- (simdat
    %>% mutate(NULL
             , truecuminc = cumsum(incidence)
             , report = ifelse(is.na(conv_incidence),0,conv_incidence)
             , cumreport = cumsum(report)
             , htfill = ifelse(is.na(ht),0,ht)
             , htfrac = ht/report
             , cumht = cumsum(htfill)
             , estcuminc = cumreport+cumht
               )
	%>% select(Date, cumreport, truecuminc, estcuminc, htfrac)
	%>% pivot_longer(!Date, names_to = "type", values_to = "value")
)

print(dat)

saveVars(dat)



