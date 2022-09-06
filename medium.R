library(shellpipes)
rpcall("med.Rout med.R")
rpcall("medium.Rout medium.R")

new_c_prop <- 0.5

saveVars(new_c_prop)
