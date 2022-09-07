library(McMasterPandemic)
library(shellpipes)
rpcall("simulate.Rout simulate.R model_definition.rda")
rpcall("med.simulate.Rout simulate.R model_definition.rda med.rda")
rpcall("medium.simulate.Rout simulate.R model_definition.rda medium.rda")
rpcall("low.simulate.Rout simulate.R model_definition.rda low.rda")
rpcall("high.simulate.Rout simulate.R model_definition.rda high.rda")

loadEnvironments()

model <- (model
	%>% update_params(c_prop = reportProp)
)

simdat <- simulation_history(model)

print(head(simdat))

saveEnvironment()
