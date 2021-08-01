library(tidyverse)
library(rstan)
library(reshape2)
rstan_options(auto_write = TRUE)
options(mc.cores=4)

args <- commandArgs(trailingOnly=TRUE)
model_name <- args[1]
iterations <- 10
chains <- 1

stan_data <- readRDS("data/processed/reproductives_stan_data.rds")
model <- stan_model(paste0("src/stan/", model_name, ".stan"))
fit <- sampling(model, data=stan_data,
                iter=iterations, chains=chains,
                thin=2)
filename <- paste0("data/processed/stan_fits/", model_name, ".rds")
saveRDS(fit, filename)
