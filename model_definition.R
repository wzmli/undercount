library(McMasterPandemic)
library(shellpipes)

loadEnvironments()


params = c(beta = beta
	, gamma = gamma
	, N = N
	, c_prop = c_prop
	, c_delay_cv = c_delay_cv
	, c_delay_mean = c_delay_mean
	, disp = disp
)


## Defining vanilla flexmodel
model <- flexmodel(params = params
	, state = state
	, start_date = start_date
	, end_date = end_date
	, do_hazard = TRUE
	, do_make_state = FALSE
)


model <- (model
  %>% add_rate("S", "I", ~ (1/N) * (beta) * (I))
  %>% add_rate("I", "R", ~ (gamma))
  %>% add_sim_report_expr('incidence', ~ (S_to_I) * (S))
  %>% add_conv("incidence", c_prop = "c_prop")
  %>% update_error_dist(conv_incidence ~ negative_binomial("disp"))
)


model

saveEnvironment()
