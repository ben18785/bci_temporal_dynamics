# fits combined birth-death statistical model

library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores=4)

args <- commandArgs(trailingOnly=TRUE)
iterations <- as.numeric(args[1])
chains <- as.numeric(args[2])
thin <- as.numeric(args[3])

data_stan <- readRDS("data/processed/reproductives_stan_birth_death_data.rds")

model <- stan_model("src/stan/birth_and_death.stan")

fit <- sampling(model, data=data_stan, iter=iterations, chains=chains, thin=thin)

saveRDS(fit, "data/processed/stan_fits/birth_death.rds")

