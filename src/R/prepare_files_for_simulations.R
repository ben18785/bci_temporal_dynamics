# gets files into simulation format

library(tidyverse)

# split birth-death into wide format and have one file for
# birth betas, another for death p_survices
df <- readRDS("data/processed/birth_death_estimates.rds")

df_birth <- df %>%
  select(iterations, name, beta) %>%
  pivot_wider(id_cols=c(name),
              names_from=iterations,
              values_from=beta)
write.csv(df_birth, "data/processed/birth_death_betas.csv")

df_survive <- df %>%
  select(iterations, name, p_survive_annual) %>%
  pivot_wider(id_cols=c(name),
              names_from=iterations,
              values_from=p_survive_annual)
write.csv(df_survive, "data/processed/birth_death_survive_annual.csv")

# get posterior medians for birth betas and p_survive_annual
df_meds <- df %>%
  group_by(name) %>%
  summarise(beta=median(beta),
            p_survive_annual=median(p_survive_annual))
write.csv(df_meds, "data/processed/birth_death_medians.csv")

# get deltas
fit <- readRDS("data/processed/stan_fits/birth_death.rds")
delta <- median(rstan::extract(fit, "delta")[[1]])
write.csv(tibble(delta=delta), "data/processed/birth_death_delta.csv",
          row.names = F)
