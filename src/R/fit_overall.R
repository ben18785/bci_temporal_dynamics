library(tidyverse)
library(rstan)
library(reshape2)
rstan_options(auto_write = TRUE)
options(mc.cores=4)

args <- commandArgs(trailingOnly=TRUE)
model_name <- args[1]
iterations <- as.numeric(args[2])
chains <- as.numeric(args[3])
thin <- as.numeric(args[4])

stan_data <- readRDS("data/processed/reproductives_stan_data.rds")
model <- stan_model(paste0("src/stan/", model_name, ".stan"))
fit <- sampling(model, data=stan_data,
                iter=iterations, chains=chains,
                thin=thin)
filename <- paste0("data/processed/stan_fits/", model_name, ".rds")
saveRDS(fit, filename)
