dd <- read.csv("monkeypox_dat.csv", comment="#")
a <- 1/dd$ratio
print(a)
## upper bound on ascertainment ratio?
with(dd,est/obs_cases)
