library(tidyverse)

s <- read.csv("data/processed/julia_runs/Exp-1_Wildtype-Extension/exp_1-1_1_1_1_1.csv")

s1 <-s %>%
  filter(censusyear<=2015) %>%
  select(simulation_nr, censusyear, species, N_present) %>%
  group_by(simulation_nr, censusyear) %>%
  mutate(N_total=sum(N_present)) %>%
  mutate(freq=N_present/N_total) %>%
  ungroup() %>%
  group_by(species, censusyear) %>%
  summarize(freq_est=quantile(freq, 0.5), freq_LCI=quantile(freq, 0.025), freq_UCI=quantile(freq, 0.975))

write.csv(s1, "data/processed/exp_1_counts.csv")
