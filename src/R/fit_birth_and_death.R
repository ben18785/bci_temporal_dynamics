# fits combined birth-death statistical model

library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores=4)

df <- readRDS("data/processed/bci_cleaned.rds")

# birth model -------

# calculate first generation when each species appeared
first_df <- df %>%
  mutate(censusyear=as.numeric(as.factor(censusyear))) %>%
  filter(N_present>0) %>%
  group_by(species) %>%
  summarise(first_year=first(censusyear))

# calculate mutant counts
mutant_df <- first_df %>%
  right_join(df) %>%
  mutate(censusyear=as.numeric(as.factor(censusyear))) %>%
  filter(censusyear==first_year) %>%
  group_by(first_year) %>%
  summarise(x=sum(N_born))
mutant_df <- tibble(first_year=seq(2, 8, 1)) %>%
  left_join(mutant_df) %>%
  mutate(x=ifelse(is.na(x), 0, x))

# calculate variant counts in each gen: parents
## find gen when first of each species occurred for ordering
order_df <- first_df %>%
  arrange(first_year) %>%
  mutate(species_id=seq_along(first_year))
## active variant count
activeVariantCount <- order_df %>%
  group_by(first_year) %>%
  summarise(x=n_distinct(species)) %>%
  ungroup() %>%
  right_join(tibble(first_year=seq(1, 8, 1))) %>%
  mutate(x=ifelse(is.na(x), 0, x)) %>%
  pull(x) %>%
  cumsum()
## parent count
counts_parents <- df %>%
  left_join(order_df) %>%
  arrange(species_id, censusyear) %>%
  filter(censusyear < 2015) %>%
  select(species_id, censusyear, N_present) %>%
  pivot_wider(id_cols = "censusyear", names_from = "species_id", values_from = "N_present") %>%
  select(-censusyear) %>%
  as.matrix() %>%
  t()
## offspring count
counts_offspring <- df %>%
  left_join(order_df) %>%
  arrange(species_id, censusyear) %>%
  filter(censusyear > 1982) %>%
  select(species_id, censusyear, N_born) %>%
  pivot_wider(id_cols = "censusyear", names_from = "species_id", values_from = "N_born") %>%
  select(-censusyear) %>%
  as.matrix() %>%
  t()
tmp <- counts_offspring / counts_parents

# need an index vector in each period dictating whether parents are zero
index_parents <- apply(counts_parents %>% t(), 1, function(x) which(x>0))

# active variants: non-zero parents in each generation
activeVariantCount <- map_dbl(index_parents, length)


# deaths -------
df <- readRDS("data/processed/bci_cleaned.rds") %>%
  mutate(N_survive=N_present-N_born) %>%
  mutate(N_parents=N_survive+N_died) %>%
  mutate(p_survive=N_survive / N_parents) %>%
  mutate(p_offspring=N_born / N_parents)

df_short <- df %>%
  filter(censusyear>1982) %>%
  filter(N_parents!=0) %>%
  droplevels() %>%
  mutate(year_gap=if_else(censusyear==1985, 3, 5)) %>%
  left_join(order_df) %>%
  arrange(species_id) %>%
  mutate(species_death = species_id)

# fit model -------
data_stan <-
