# Extract birth and death parameters from Stanfit

library(tidyverse)
library(rstan)

fit <- readRDS("data/processed/stan_fits/birth_death.rds")
load("data/processed/birth_death_image.RData")

# survival probabilities
p_survive <- rstan::extract(fit, "p_survive_annual")[[1]]
colnames(p_survive) <- order_df$species
p_survive <- p_survive %>%
  as.data.frame() %>%
  mutate(iterations=seq_along(`Abarema macradenia`)) %>%
  pivot_longer(-iterations)

# birth betas
beta <- rstan::extract(fit, "beta")[[1]] %>%
  as.data.frame()
colnames(beta) <- order_df$species[1:(nrow(order_df) - 1)]
beta$V1 <- 0
colnames(beta)[ncol(beta)] <- last(as.character(order_df$species))
beta <- beta %>%
  mutate(iterations=seq_along(`Abarema macradenia`)) %>%
  pivot_longer(-iterations)

# combine birth and death
combined <- p_survive %>%
  rename(p_survive_annual=value) %>%
  left_join(beta) %>%
  rename(beta=value)

saveRDS(combined, "data/processed/birth_death_estimates.rds")
