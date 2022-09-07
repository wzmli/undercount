library(McMasterPandemic)
library(shellpipes)
rpcall("model_definition.Rout model_definition.R parameters.rda states.rda")

loadEnvironments()


params = c(beta = beta
	, gamma = gamma
	, N = N
	, rProp = rProp
)


## Defining vanilla flexmodel
model <- flexmodel(params = params
	, state = state
	, start_date = start_date
	, end_date = end_date
	, do_hazard = FALSE
	, do_make_state = FALSE
)


model <- (model
  %>% add_rate("S", "I", ~ (1/N) * (beta) * (I))
  %>% add_rate("I", "R", ~ (gamma))
  %>% add_sim_report_expr('incidence', ~ (S_to_I) * (S))
)


model

saveEnvironment()
