library(McMasterPandemic)
library(shellpipes)
rpcall("states.Rout states.R parameters.rda")

loadEnvironments()
epi_states <- c("S", "I", "R")

state <- layered_zero_state(epi_states)

state["S"] <- S0
state["I"] <- I0

saveEnvironment()
