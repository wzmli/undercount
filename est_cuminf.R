library(McMasterPandemic)
library(tidyverse)
library(shellpipes)
rpcall("est_cuminf.Rout est_cuminf.R simulate.rda parameters.rda")
loadEnvironments()

## 

htfun <- function(n){
	n_1 <- dplyr::lag(n, 1)
        return((n*(n-1))/(1+n_1))
}


print(head(simdat))

dat0 <- (simdat
	%>% filter(I > I0)
   %>% mutate(NULL
		, truecuminc = cumsum(incidence)
      , report = c_prop*incidence 
      , ht = htfun(report)
      , cumreport = cumsum(report)
      , htfill = ifelse(is.na(ht),0,ht)
      , htfrac = ht/report
      , cumht = cumsum(htfill)
      , estcuminc = cumreport+cumht
	)
   %>% select(Date, cumreport, truecuminc, estcuminc, htfrac)
)

dat <- (dat0
    %>% pivot_longer(!Date, names_to = "type", values_to = "value")
)

print(dat)

summ <- with(dat0,
             c(min = min(htfrac, na.rm = TRUE),
               max = max(htfrac, na.rm = TRUE),
               mean = mean(htfrac, na.rm  = TRUE))
             )

saveVars(dat, summ)



