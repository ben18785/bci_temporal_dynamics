library(rstan)
library(posterior)

check_diagnostics <- function(filename) {
  fit <- readRDS(filename)
  fit_diagnostics <- summarise_draws(fit)
  rhat_above_1.01 <- sum(fit_diagnostics$rhat > 1.01, na.rm = T)
  ess_bulk_below_400 <- sum(fit_diagnostics$ess_bulk < 400, na.rm = T)
  ess_tail_below_400 <- sum(fit_diagnostics$ess_tail < 400, na.rm = T)
  list(rhat=rhat_above_1.01,
       ess_bulk=ess_bulk_below_400,
       ess_tail=ess_tail_below_400)
}

diagnostics_1 <- check_diagnostics("data/processed/stan_fits/overall_freq_dependent.rds")
diagnostics_2 <- check_diagnostics("data/processed/stan_fits/overall_freq_independent.rds")
diagnostics_3 <- check_diagnostics("data/processed/stan_fits/overall_neutral.rds")

diagnostic_list <- list(overall_freq_dependent=diagnostics_1,
                        overall_freq_independent=diagnostics_2,
                        overall_neutral=diagnostics_3)

saveRDS(diagnostic_list, "data/processed/stan_fits/diagnostics.rds")
