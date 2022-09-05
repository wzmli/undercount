library(McMasterPandemic)
library(shellpipes)
rpcall("simulate.Rout simulate.R model_definition.rda")
rpcall("med.simulate.Rout simulate.R model_definition.rda med.rda")
rpcall("high.simulate.Rout simulate.R model_definition.rda high.rda")
rpcall("low.simulate.Rout simulate.R model_definition.rda low.rda")

loadEnvironments()

model <- (model
	%>% update_params(c_prop = new_c_prop)
)

simdat <- simulation_history(model)

print(head(simdat))

saveEnvironment()
