library(shellpipes)

start_date <- as.Date("2022-01-01")
end_date <- as.Date("2023-01-01")

N <- 1e6
I0 <- 10
S0 <- N - I0

## Rate parameters
beta <- 0.4
gamma <- 0.3

## Convolution
c_prop <- 0.8
c_delay_cv <- 1
c_delay_mean <- 0.5

disp <- 1000

saveEnvironment()
