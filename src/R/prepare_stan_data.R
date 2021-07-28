rm(list=ls())
library(tidyverse)
library(reshape2)

df <- read.csv("data/processed/BCI_summary_data_forben_reproductivesonly_2Oct.csv")

# determine first year each species appears and sort
years <- sort(unique(df$censusyear))
df_first <- df %>%
  filter(N_present > 0) %>%
  group_by(genus_species_subspecies) %>%
  dplyr::summarise(first_year=min(censusyear)) %>%
  ungroup() %>%
  mutate(firstAppearance=match(first_year, years))

# determine count of newly arriving species in each year subsequent to 1982
df <- df %>%
  left_join(df_first)
lMutantCounts <- vector(length = 7)
for(i in 1:7){
  aTempDF <- filter(df, firstAppearance==(i + 1)) %>%
    filter(censusyear==first_year)
  lMutantCounts[i] <- sum(aTempDF$N_present)
}

# create matrix of counts of species in each year (with later arriving species
# towards bottom)
df <- df %>%
  arrange(first_year)
counts <- df %>%
  select(genus_species_subspecies, censusyear, N_present) %>%
  pivot_wider(id_cols = genus_species_subspecies,names_from=censusyear,
              values_from=N_present) %>%
  select(-genus_species_subspecies) %>%
  as.matrix()

# number of variants active in each year
df_active <- df %>%
  ungroup() %>%
  dplyr::group_by(censusyear) %>%
  dplyr::summarise(n=sum(censusyear >= first_year))

# index representing census year when each species appeared
firstAppearance <- df %>% select(genus_species_subspecies, firstAppearance) %>% unique()

# format for Stan
stan_data <- list(N=n_distinct(df$censusyear),
                   K=n_distinct(df$genus_species_subspecies),
                   firstAppearance=firstAppearance$firstAppearance,
                   mutantCounts=lMutantCounts,
                   counts=counts,
                   activeVariantCount=df_active$n,
                   names=firstAppearance$genus_species_subspecies)
saveRDS(stan_data, "data/processed/reproductives_stan_data.rds")
