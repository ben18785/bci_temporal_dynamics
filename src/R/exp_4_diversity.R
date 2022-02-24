library(tidyverse)
library(vegan)
library(data.table)

file_id <- list.files("data/processed/julia_runs/Exp-4_Drift-Increase/", pattern = "*.csv")
file_id <- map_chr(file_id, ~paste0("data/processed/julia_runs/Exp-4_Drift-Increase/", .))
a2 <- lapply(file_id, read_csv, col_names=TRUE)
a3 <- lapply(a2, as.data.frame)
files <- file_id
a4 <- mapply(cbind, a3, "file_id"=files, SIMPLIFY=F)
a5 <- rbindlist(a4)

a6 <- a5 %>%
  filter(SVt==1) %>%
  filter(BBt==1) %>%
  filter(censusyear==2015) %>%
  mutate(censussize=83648*Dt)

# get species richness for  each replicate
s1 <- a6 %>%
  group_by(censussize,censusyear,simulation_nr) %>%
  filter(N_present>0) %>%
  summarize(D_species_richness=length(species))

# get species evenness for  each replicate
s2 <- a6 %>%
  group_by(censussize,censusyear,simulation_nr) %>%
  summarize(D_simpson=diversity(N_present, index = "simpson"), N_runs=length(unique(simulation_nr))) %>%
  mutate(H_simpson=1/(1-D_simpson))

s_both <- s1 %>%
  left_join(s2)

write.csv(s_both, "data/processed/exp_4_diversity.csv")
