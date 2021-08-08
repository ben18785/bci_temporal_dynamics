library(rstan)
library(posterior)
source("src/R/helper.R")

diagnostics_1 <- check_diagnostics("data/processed/stan_fits/birth_death.rds")

saveRDS(diagnostics_1, "data/processed/stan_fits/diagnostics_birth_death.rds")
