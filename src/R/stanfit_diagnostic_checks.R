library(rstan)
library(posterior)
source("src/R/helper.R")

diagnostics_1 <- check_diagnostics("data/processed/stan_fits/overall_freq_dependent.rds")
diagnostics_2 <- check_diagnostics("data/processed/stan_fits/overall_freq_independent.rds")
diagnostics_3 <- check_diagnostics("data/processed/stan_fits/overall_neutral.rds")

diagnostic_list <- list(overall_freq_dependent=diagnostics_1,
                        overall_freq_independent=diagnostics_2,
                        overall_neutral=diagnostics_3)

saveRDS(diagnostic_list, "data/processed/stan_fits/diagnostics.rds")
