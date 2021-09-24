# removes Lazarus species for quartered data

library(lubridate)
library(stringr)
library(dplyr)
library(tidyr)

a10 <- readRDS("data/processed/bci_reproductives_quartered.rds")

# remove Lazarus individuals -------

# Check for Lazarus individuals. Here a Lazarus will appear
# as 1 since it will be present==0 at time t and present=1 at time t+1
a11 <- a10 %>%
  select(tree_id, censusyear, present) %>%
  filter(present==1) %>%
  group_by(tree_id) %>%
  mutate(yearfirstseen=min(censusyear), yearlastseen=max(censusyear)) %>%
  select(-c(censusyear, present)) %>%
  unique()
a12 <- merge(a10, a11, by="tree_id")

l <- a12 %>%
  arrange(tree_id, censusyear) %>%
  group_by(tree_id) %>%
  filter(censusyear > yearfirstseen) %>%
  mutate(Lazarus=present-lag(present, n=1L)) %>%
  filter(Lazarus==1)

# Fix the Lazarus individuals. We assume that an
# individual is present in all censusyears from when
# it first appears to when it last appears.
a12 <- a12 %>%
  arrange(species, tree_id) %>%
  group_by(tree_id) %>%
  mutate(present=ifelse(censusyear>=yearfirstseen & censusyear<=yearlastseen, 1, 0))

# check for Lazarus individuals
l <- a12 %>%
  arrange(tree_id, censusyear) %>%
  group_by(tree_id) %>%
  filter(censusyear>yearfirstseen) %>%
  mutate(Lazarus=present-lag(present, n=1L)) %>%
  filter(Lazarus==1)

# check there are none as expected
stopifnot(nrow(l) == 0)

# eliminate Lazarus species -----
# Count the number of trees present in each year
a13 <- a12 %>%
  group_by(species, quarter, censusyear) %>%
  summarize(N_present=sum(present))

# Identify Lazarus species
# A potential lazarus species is one in which the
# last year present > the first year absent.
# For example, one which is not present in 2005 and then
# reappears in 2015.

# Identify, for each species, the first year absent,
# i.e., in which N_present==0
l2 <- a13 %>%
  filter(N_present==0) %>%
  group_by(species, quarter) %>%
  summarize(firstyearabsent=min(censusyear)) %>%
  as.data.frame()

# Identify, for each species, the last year present,
# i.e., in which N_present>0
l3 <- a13 %>%
  filter(N_present>0) %>%
  group_by(species, quarter) %>%
  summarize(lastyearpresent=max(censusyear)) %>%
  as.data.frame()

l4 <- left_join(l3, l2, all.x=TRUE)
l4[is.na(l4)]  <- 2020
l4 <- l4 %>%
  arrange(desc(firstyearabsent))

# identify Lazarus species
l4$Lazarus <- ifelse(l4$lastyearpresent > l4$firstyearabsent, 1, 0)
l4 <- l4 %>%
  filter(Lazarus==1)

# get counts by year for potentially Lazarus species
temp <- a13 %>%
  left_join(l4) %>%
  filter(Lazarus==1)

laz <- temp %>%
  select(species, quarter) %>%
  unique()

# go through species by species and fix
for(i in seq_along(laz$species)) {
  temp_short <- temp %>%
    filter(species==laz$species[i],
           quarter==laz$quarter[i])
  non_zero_ids <- which(temp_short$N_present > 0)
  zero_ids <- which(temp_short$N_present == 0)
  min_non_zero_id <- min(non_zero_ids)
  zero_ids_after_non_zero <- zero_ids[zero_ids > min_non_zero_id]
  if(length(zero_ids_after_non_zero) > 0) {
    first_zero_id_after_non_zero <- first(zero_ids_after_non_zero)
    n <- nrow(temp_short)
    temp_short$N_present[first_zero_id_after_non_zero:n] <- 0
  }
  if(i == 1)
    l6 <- temp_short
  else
    l6 <- l6 %>%
    bind_rows(temp_short)
}
l6 <- l6 %>%
  arrange(species) %>%
  select(-c(lastyearpresent, firstyearabsent, Lazarus))

# get the non-Lazarus species and combine with the Lazarus species
laz <- laz %>%
  mutate(Lazarus=1)
l7 <- a13 %>%
  left_join(laz) %>%
  filter(is.na(Lazarus)) %>%
  select(-Lazarus)
l6 <- as.data.frame(l6)
l7 <- as.data.frame(l7)
l8 <- rbind(l6, l7)

# get the last year present for each species
l9 <- l8 %>%
  filter(N_present > 0) %>%
  group_by(species, quarter) %>%
  filter(censusyear==max(censusyear)) %>%
  arrange(censusyear)
l9 <- l9 %>% select(species, censusyear)
names(l9) <- c("quarter", "species", "cutoffyear")

# put with the original data
a14 <- merge(a12, l9, by=c("species", "quarter"))

# now zero all individuals that are present after the cutoffyear
a14 <- a14 %>%
  mutate(present=ifelse(censusyear>cutoffyear, 0, present))

# recalculate N_present now that Lazarus species have been eliminated
a15 <- a14 %>%
  group_by(species, quarter, censusyear) %>%
  summarize(N_present=sum(present))

# N_born -----
# count the number of trees born in each year
a16 <- a14 %>%
  filter(present==1) %>%
  group_by(tree_id) %>%
  filter(censusyear==min(censusyear)) %>%
  group_by(species, quarter, censusyear) %>%
  summarize(N_born=length(tree_id))

# Combine with N_present data
a17 <- left_join(a15, a16)
a17[is.na(a17)]  <-  0

# N_died ------
# To find N_died between one census year and the next first
# find the last census year that a tree was seen. It died before
# the following census year. And then calculate how many individuals
# of each species died in each year.
a18 <- a14 %>%
  filter(present==1) %>%
  arrange(tree_id, censusyear) %>%
  group_by(tree_id) %>%
  filter(censusyear==max(censusyear)) %>%
  group_by(species, quarter, censusyear) %>%
  summarize(N_died=length(tree_id))

# adjust the years to give the year of death
censusyear <- sort(unique(a18$censusyear))
a19 <- as.data.frame(censusyear)
a19$deathyear <- c("1985","1990","1995","2000","2005","2010","2015", "NA")
a20 <- merge(a18, a19, by="censusyear") %>%
  mutate(censusyear=deathyear) %>%
  select(-deathyear)

# combine with N_present and N_born
a21 <- left_join(a17, a20)
a21[is.na(a21)] <-  0

saveRDS(a21, "data/processed/bci_cleaned_quartered.rds")
