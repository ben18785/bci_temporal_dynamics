library(tidyverse)
library(vegan)

s <- read.csv("data/processed/julia_runs/Exp-1_Wildtype-Extension/exp_1-1_1_1_1_1.csv")

s6 <- s %>%
  filter(censusyear=="2498") %>%
  group_by(simulation_nr, censusyear) %>%
  mutate(N_total=sum(N_present)) %>%
  mutate(Freq=N_present/N_total) %>%
  arrange(simulation_nr, desc(Freq)) %>%
  slice(1:2)

# calculate most fit out of non-migrant species
s7 <- s6 %>%
  mutate(rank=1:2) %>%
  ungroup() %>%
  group_by(species, rank) %>%
  summarize(N=length(species)) %>%
  pivot_wider(c(species), names_from = rank, values_from = N, values_fill = 0) %>%
  filter(!str_detect(species, "migrant"))

s8 <- s6 %>%
  group_by(simulation_nr) %>%
  summarize(sum_Freq=sum(Freq)) %>%
  summarize(est=quantile(sum_Freq, 0.5), LCI=quantile(sum_Freq, 0.025),UCI=quantile(sum_Freq, 0.975))

# replace species names by the actual most abundant ones
s9 <- s %>%
  group_by(censusyear, simulation_nr) %>%
  mutate(N_total=sum(N_present)) %>%
  mutate(Freq=N_present/N_total) %>%
  filter(species==s7$species[1]|species==s7$species[2]) %>%
  group_by(species, censusyear) %>%
  summarize(est=quantile(Freq, 0.5), LCI=quantile(Freq, 0.025),UCI=quantile(Freq, 0.975))

write.csv(s9, "data/processed/exp_1_most_abundant.csv")
