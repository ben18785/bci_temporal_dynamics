# script generates simulations from the hierarchical model over
# (p, beta) representing the death-birth parameters

library(tidyverse)
source("src/R/helper.R")
library(mvtnorm)

fit <- readRDS("data/processed/stan_fits/birth_death.rds")

mu <- rstan::extract(fit, "mu")[[1]]
sigma <- rstan::extract(fit, "sigma")[[1]]
rho <- rstan::extract(fit, "rho")[[1]]

nreps <- 10000
beta_l <- vector(length=nreps)
p <- vector(length=nreps)
for(i in 1:nreps) {
  idx <- sample(1:nrow(mu), 1)
  vals <- rmvrnorm2D(1, mu[idx, 1], mu[idx, 2], sigma[idx, 1],
             sigma[idx, 2], rho[idx])
  beta <- vals[1, 1]
  while(abs(beta) > 1) {
    vals <- rmvrnorm2D(1, mu[idx, 1], mu[idx, 2], sigma[idx, 1],
                       sigma[idx, 2], rho[idx])
    beta <- vals[1, 1]
  }
  logit_p <- vals[1, 2]
  beta_l[i] <- beta
  p[i] <- inv_logit(logit_p)
}

df <- tibble(beta=beta_l, prob=p)

saveRDS(df, "data/processed/population_birth_death_samples.rds")
write.csv(df, "data/processed/population_birth_death_samples.csv",
          row.names = F)
