library(McMasterPandemic)
library(shellpipes)
rpcall("simulate.Rout simulate.R model_definition.rda")

loadEnvironments()

simdat <- simulation_history(model)

print(head(simdat))

saveEnvironment()
