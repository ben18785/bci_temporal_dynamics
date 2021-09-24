# extracts betas by species from different quarter estimates

library(tidyverse)
library(rstan)
library(posterior)

# check diagnostics on fits -------
check_diagnostics <- function(filename) {
  fit <- readRDS(filename)$fit
  fit_diagnostics <- summarise_draws(fit)
  rhat_above_1.01 <- sum(fit_diagnostics$rhat > 1.01, na.rm = T)
  ess_bulk_below_400 <- sum(fit_diagnostics$ess_bulk < 400, na.rm = T)
  ess_tail_below_400 <- sum(fit_diagnostics$ess_tail < 400, na.rm = T)
  list(rhat=rhat_above_1.01,
       ess_bulk=ess_bulk_below_400,
       ess_tail=ess_tail_below_400)
}

diagnostics_1 <- check_diagnostics("data/processed/stan_fits/quartered_1.rds")
diagnostics_2 <- check_diagnostics("data/processed/stan_fits/quartered_2.rds")
diagnostics_3 <- check_diagnostics("data/processed/stan_fits/quartered_3.rds")
diagnostics_4 <- check_diagnostics("data/processed/stan_fits/quartered_4.rds")
stopifnot(Reduce(`+`, diagnostics_1) == 0)
stopifnot(Reduce(`+`, diagnostics_2) == 0)
stopifnot(Reduce(`+`, diagnostics_3) == 0)
stopifnot(Reduce(`+`, diagnostics_4) == 0)

# extract betas and compare ------
df <- readRDS("data/processed/bci_cleaned_quartered.rds") %>%
  ungroup()
quarters <- unique(df$quarter)

extract_beta_by_species <- function(quarter_id) {
  filename <- paste0("data/processed/stan_fits/quartered_", quarter_id, ".rds")
  result <- readRDS(filename)
  stan_data <- result$stan_data
  fit <- result$fit
  beta <- rstan::extract(fit, "beta")[[1]] %>%
    as.data.frame()
  colnames(beta) <- stan_data$names
  beta$iterations <- seq_along(beta$`Acalypha macrostachya`)
  beta <- beta %>%
    pivot_longer(-iterations) %>%
    mutate(quarter=quarters[quarter_id])
  beta
}

for(i in seq_along(quarters)) {
  beta_temp <- extract_beta_by_species(i)
  if(i == 1)
    beta <- beta_temp
  else
    beta <- beta %>% bind_rows(beta_temp)
}

# record only those species present over all quarters
beta_wider <- beta %>%
  rename(species=name) %>%
  group_by(species, quarter) %>%
  summarise(value=median(value)) %>%
  ungroup() %>%
  pivot_wider(id_cols = "species", values_from=value, names_from=quarter) %>%
  drop_na()
saveRDS(beta_wider, "data/processed/quartered_betas.rds")
