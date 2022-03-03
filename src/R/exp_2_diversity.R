library(tidyverse)
library(vegan)
library(data.table)

file_id <- list.files("data/processed/julia_runs/Exp-2_Migration-Revamping/", pattern = "*.csv")
file_id <- map_chr(file_id, ~paste0("data/processed/julia_runs/Exp-2_Migration-Revamping/", .))
a2 <- lapply(file_id, read_csv, col_names=TRUE)
a3 <- lapply(a2, as.data.frame)
files <- file_id
a4 <- mapply(cbind, a3, "file_id"=files, SIMPLIFY=F)
a5 <- rbindlist(a4)

s1 <- a5 %>%
  group_by(censusyear,simulation_nr, SVt, BBt, Dt, Mt) %>%
  filter(N_present>0) %>%
  summarize(D_species_richness=length(species))

s2 <- a5 %>%
  group_by(censusyear,simulation_nr, SVt, BBt, Dt, Mt) %>%
  summarize(D_simpson=diversity(N_present, index = "simpson")) %>%
  mutate(H_simpson=1/(1-D_simpson))

s_both <- s1 %>%
  left_join(s2)

write.csv(s_both, "data/processed/exp_2_diversity.csv")
