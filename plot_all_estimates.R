library(tidyverse)

library(shellpipes)

el <- loadEnvironmentList(trim=".estimate.*")

dat <- el %>% map(~ .x[["dat"]]) %>% bind_rows(.id="Scenario")

summary(dat)
summary(dat %>% mutate_if(is.character, as.factor))

