library(rstan)
library(loo)
library(tidyverse)

diagnostic_check <- readRDS("data/processed/stan_fits/diagnostics_holdout.rds") %>%
  mutate(value=as.numeric(as.character(value)))
stopifnot(sum(diagnostic_check$value) == 0)

f_get_fit <- function(modelname, holdout) {
  filename <- paste0("data/processed/stan_fits/",
                     modelname, "_hold_out_", holdout, ".rds")
  print(filename)
  fit <- readRDS(filename)
  log_like <- extract_log_lik(fit, 'vLogLikelihood')
  mean(log_like[, holdout])
}

f_get_all_holdouts <- function(modelname) {
  log_likes <- map_dbl(seq(1, 7, 1), ~f_get_fit(modelname, .))
  log_likes
}

log_like_neutral <- f_get_all_holdouts("overall_neutral")
log_like_freqdep <- f_get_all_holdouts("overall_freq_dependent")
log_like_freqind <- f_get_all_holdouts("overall_freq_independent")

test <- tibble(
  neutral=log_like_neutral,
  freqdep=log_like_freqdep,
  freqind=log_like_freqind)

saveRDS(test, "data/processed/model_comparison_hold_out.rds")
