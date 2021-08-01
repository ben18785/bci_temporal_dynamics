library(tidyverse)
library(reshape2)

df <- readRDS("data/processed/bci_cleaned.rds")

# determine first year each species appears and sort
years <- sort(unique(df$censusyear))
df_first <- df %>%
  filter(N_present > 0) %>%
  group_by(species) %>%
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
  select(species, censusyear, N_present) %>%
  pivot_wider(id_cols = species,names_from=censusyear,
              values_from=N_present) %>%
  select(-species) %>%
  as.matrix()

# number of variants active in each year
df_active <- df %>%
  ungroup() %>%
  dplyr::group_by(censusyear) %>%
  dplyr::summarise(n=sum(censusyear >= first_year))

# index representing census year when each species appeared
firstAppearance <- df %>% select(species, firstAppearance) %>% unique()

# format for Stan
stan_data <- list(N=n_distinct(df$censusyear),
                   K=n_distinct(df$species),
                   firstAppearance=firstAppearance$firstAppearance,
                   mutantCounts=lMutantCounts,
                   counts=counts,
                   activeVariantCount=df_active$n,
                   names=firstAppearance$species)
saveRDS(stan_data, "data/processed/reproductives_stan_data.rds")
