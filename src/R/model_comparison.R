rm(list=ls())
library(rstan)

fit_freqDep_homo <- readRDS("data/processed/stan_fits/overall_freq_dependent.rds")
loo_freqIndependent <- readRDS("data/processed/stan_fits/overall_freq_independent.rds")
fit_neutral <- readRDS("data/processed/stan_fits/overall_neutral.rds")

# determine loo on fits and compare them
loo_freqDep_homo <- loo(extract_log_lik(fit_freqDep_homo,'vLogLikelihood'))
loo_freqIndependent <- loo(extract_log_lik(fit_freqIndependent,'vLogLikelihood'))
loo_neutral <- loo(extract_log_lik(fit_neutral,'vLogLikelihood'))
test <- compare(loo_freqDep_homo,loo_freqIndependent,loo_neutral) %>%
  as.data.frame()

saveRDS(test, "../data/process/model_comparison.rds")
