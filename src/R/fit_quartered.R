# fits frequency-independent models for each of the quartered datasets

library(tidyverse)
library(rstan)
library(reshape2)
rstan_options(auto_write = TRUE)
options(mc.cores=4)
args <- commandArgs(trailingOnly=TRUE)

quarter_id <- as.numeric(args[1])
iterations <- as.numeric(args[2])
chains <- as.numeric(args[3])
thin <- as.numeric(args[4])

df <- readRDS("data/processed/bci_cleaned_quartered.rds") %>%
  ungroup()

quarters <- unique(df$quarter)
a_quarter <- quarters[quarter_id]
df <- df %>%
  filter(quarter==a_quarter)

years <- sort(unique(df$censusyear))
df_first <- df %>%
  filter(N_present > 0) %>%
  group_by(species) %>%
  dplyr::summarise(first_year=min(censusyear)) %>%
  ungroup() %>%
  mutate(firstAppearance=match(first_year, years))

df <- df %>%
  left_join(df_first)
lMutantCounts <- vector(length = 7)
for(i in 1:7){
  aTempDF <- filter(df, firstAppearance==(i + 1)) %>%
    filter(censusyear==first_year)
  lMutantCounts[i] <- sum(aTempDF$N_present)
}

# reorder according to first appearance
df <- df %>%
  arrange(first_year)
counts <- df %>%
  select(species, censusyear, N_present) %>%
  pivot_wider(id_cols = species,names_from=censusyear,
              values_from=N_present) %>%
  select(-species) %>%
  as.matrix()

# activeVariantCount
df_active <- df %>%
  ungroup() %>%
  dplyr::group_by(censusyear) %>%
  dplyr::summarise(n=sum(censusyear >= first_year))

firstAppearance <- df %>%
  select(species, firstAppearance) %>%
  unique()

stan_data <- list(N=n_distinct(df$censusyear),
                   K=n_distinct(df$species),
                   firstAppearance=firstAppearance$firstAppearance,
                   mutantCounts=lMutantCounts,
                   counts=counts,
                   activeVariantCount=df_active$n,
                   names=firstAppearance$species,
                   hold_out=-99)

# fit model
model <- stan_model("src/stan/overall_freq_independent.stan")

fit <- sampling(model, data=stan_data,
                iter=iterations, chains=chains,
                thin=thin)
filename <- paste0("data/processed/stan_fits/quartered_", quarter_id, ".rds")

result <- list(fit=fit, stan_data=stan_data)
saveRDS(result, filename)
