# script does prior simulations of the parameters p and beta
# from their hierarchical priors

library(mvtnorm)
library(tidyverse)
source("src/R/helper.R")

sample_beta_p <- function() {

  mu <- vector(length = 2)
  sigma <- vector(length = 2)

  mu[1] <- rnorm(1, 0, 0.5)
  mu[2] <- rnorm(1, 3, 0.5)

  sigma[1] <- truncated_normal(0.5, 0.5)
  sigma[2] <- truncated_normal(2, 1)

  rho <- runif(1, -1, 1)
  vals <- rmvrnorm2D(1, mu[1], mu[2], sigma[1], sigma[2], rho)
  beta <- vals[1, 1]
  logit_p <- vals[1, 2]

  p <- inv_logit(logit_p)
  list(beta=beta, p=p)
}

ndraws <- 10000
beta <- vector(length = ndraws)
p <- vector(length = ndraws)
for(i in 1:ndraws) {
  vals <- sample_beta_p()
  beta_temp <- vals$beta
  while(abs(beta_temp) > 1) {
    vals <- sample_beta_p()
    beta_temp <- vals$beta
  }

  beta[i] <- vals$beta
  p[i] <- vals$p
}

df <- tibble(beta, p)
saveRDS(df, "data/processed/prior_predictive_birth_death.rds")
