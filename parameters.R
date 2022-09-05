library(shellpipes)
rpcall("parameters.Rout parameters.R")

start_date <- as.Date("2022-01-01")
end_date <- as.Date("2023-01-01")

N <- 1e6
I0 <- 10
S0 <- N - I0

## Rate parameters
beta <- 0.6
gamma <- 0.3

# Reporting fraction
c_prop <- 0.8

saveEnvironment()
