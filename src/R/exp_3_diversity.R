# calculates diversity for experiment 3
library(tidyverse)
library(vegan)
library(data.table)

file_id <- list.files("data/processed/julia_runs/Exp-3_Sel_on-off_equal/", pattern = "*.csv")[1:2]
file_id <- map_chr(file_id, ~paste0("data/processed/julia_runs/Exp-3_Sel_on-off_equal/", .))
a2 <- lapply(file_id, read_csv, col_names=TRUE)
a3 <- lapply(a2, as.data.frame)
files <- file_id
a4 <- mapply(cbind, a3, "file_id"=files, SIMPLIFY=F)
a5 <- rbindlist(a4)

a6 <- a5 %>%
  filter(Dt==1) %>%
  filter(SVt==0 & BBt==0 |SVt==1 & BBt==1) %>%
  filter(censusyear==2015) %>%
  mutate(treatment_label=ifelse(BBt==1 & SVt==1, "selection", "no selection"))

s1 <- a6 %>%
  group_by(treatment_label,censusyear,simulation_nr) %>%
  filter(N_present>0) %>%
  summarize(D_species_richness=length(species))

s2 <- a6 %>%
  group_by(treatment_label,censusyear,simulation_nr) %>%
  summarize(D_simpson=diversity(N_present, index = "simpson")) %>%
  mutate(H_simpson=1/(1-D_simpson))

s_both <- s1 %>%
  left_join(s2)

write.csv(s_both, "data/processed/exp_3_diversity.csv")
