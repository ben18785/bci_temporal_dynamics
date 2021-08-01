library(rstan)
library(loo)
library(tidyverse)

# check that Stan models have converged ok
diagnostic_check <- readRDS("data/processed/stan_fits/diagnostics.rds")
stopifnot(Reduce(`+`, diagnostic_check[[1]]) == 0)
stopifnot(Reduce(`+`, diagnostic_check[[2]]) == 0)
stopifnot(Reduce(`+`, diagnostic_check[[3]]) == 0)

fit_freqDep_homo <- readRDS("data/processed/stan_fits/overall_freq_dependent.rds")
fit_freqIndependent <- readRDS("data/processed/stan_fits/overall_freq_independent.rds")
fit_neutral <- readRDS("data/processed/stan_fits/overall_neutral.rds")

# determine loo on fits and compare them
loo_freqDep_homo <- loo(extract_log_lik(fit_freqDep_homo,'vLogLikelihood'))
loo_freqIndependent <- loo(extract_log_lik(fit_freqIndependent,'vLogLikelihood'))
loo_neutral <- loo(extract_log_lik(fit_neutral,'vLogLikelihood'))
test <- compare(loo_freqDep_homo,loo_freqIndependent,loo_neutral) %>%
  as.data.frame()

saveRDS(test, "data/processed/model_comparison.rds")
