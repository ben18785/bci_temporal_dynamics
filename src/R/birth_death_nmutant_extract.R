library(rstan)
library(tidyverse)

fit <- readRDS("data/processed/stan_fits/birth_death.rds")

nmutants <- rstan::extract(fit, "nmutants")[[1]] %>%
  rowSums()

quants <- quantile(nmutants, c(0.025, 0.5, 0.975))
saveRDS(quants, "data/processed/nmutants_quantiles.rds")
