# extracts betas and delta from frequency independent model fits

library(rstan)
library(tidyverse)

stan_data <- readRDS("data/processed/reproductives_stan_data.rds")
fit <- readRDS("data/processed/stan_fits/overall_freq_independent.rds")

# extract beta and map to species
beta <- rstan::extract(fit, "beta")[[1]] %>%
  as.data.frame()
colnames(beta) <- stan_data$names
beta <- beta %>%
  mutate(iteration=seq_along(beta$`Acalypha diversifolia`)) %>%
  pivot_longer(-iteration) %>%
  rename(species=name)

# extract delta
delta <- rstan::extract(fit, "delta")[[1]]

complete <- list(beta=beta, delta=delta)

saveRDS(complete, "data/processed/freq_independent_parameters.rds")
