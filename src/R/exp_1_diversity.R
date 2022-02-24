# calculate Simpsons diversity from Julia runs
library(tidyverse)
library(vegan)

s <- read.csv("data/processed/julia_runs/Exp-1_Wildtype-Extension/exp_1-1_1_1_1_1.csv")
s <- s %>%
  dplyr::select(simulation_nr, censusyear, species, N_present)

# note that for species richness, we remove those species that aren't there
s1 <- s %>%
  filter(N_present>0) %>%
  group_by(censusyear, simulation_nr) %>%
  summarize(D_species_richness=length(species))

s2 <- s %>%
  group_by(censusyear, simulation_nr) %>%
  summarize(D_simpson=diversity(N_present, index = "simpson"), N_runs=length(unique(simulation_nr))) %>%
  mutate(H_simpson=1/(1-D_simpson))

s_both <- s1 %>%
  left_join(s2)

write.csv(s_both, "data/processed/exp_1_diversity.csv")
