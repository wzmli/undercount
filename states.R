library(McMasterPandemic)
library(shellpipes)

loadEnvironments()
epi_states <- c("S", "I", "R")

state <- layered_zero_state(epi_states)

state["S"] <- S
state["I"] <- I

saveEnvironment()
