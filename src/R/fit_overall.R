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
hold_out <- as.numeric(args[5])

stan_data <- readRDS("data/processed/reproductives_stan_data.rds")
stan_data$hold_out <- hold_out

model <- stan_model(paste0("src/stan/", model_name, ".stan"))
fit <- sampling(model, data=stan_data,
                iter=iterations, chains=chains,
                thin=thin)
if(hold_out < 0) {
  filename <- paste0("data/processed/stan_fits/", model_name, ".rds")
}else {
  filename <- paste0("data/processed/stan_fits/", model_name,
                     "_hold_out_", hold_out, ".rds")
}
saveRDS(fit, filename)
