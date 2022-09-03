library(McMasterPandemic)
library(tidyverse)
library(shellpipes)

loadEnvironments()

## 

htfun <- function(n){
	n_1 <- c(NA,n[-length(n)])
   return((n*n_1)/(1+n_1))
}

simdat$ht <- htfun(simdat[["conv_incidence"]])

print(head(simdat))

dat <- (simdat
	%>% mutate(NULL
		, truecuminc = cumsum(incidence)
		, report = ifelse(is.na(conv_incidence),0,conv_incidence)
		, cumreport = cumsum(report)
		, htfill = ifelse(is.na(ht),0,ht)
		, cumht = cumsum(htfill)
		, estcuminc = cumreport+cumht
	)
	%>% select(Date, cumreport, truecuminc, estcuminc)
	%>% pivot_longer(!Date, names_to = "type", values_to = "value")
)

print(dat)

saveVars(dat)



