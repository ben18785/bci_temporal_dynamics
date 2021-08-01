# This gets an initial dataset of individual reproductive trees
# and their geographic locations.

library(lubridate)
library(stringr)
library(dplyr)
library(tidyr)

# get the original BCI data
load("data/raw/bci.tree1.rdata")
load("data/raw/bci.tree2.rdata")
load("data/raw/bci.tree3.rdata")
load("data/raw/bci.tree4.rdata")
load("data/raw/bci.tree5.rdata")
load("data/raw/bci.tree6.rdata")
load("data/raw/bci.tree7.rdata")
load("data/raw/bci.tree8.rdata")

# combine data
a <- rbind(bci.tree1, bci.tree2, bci.tree3,
         bci.tree4, bci.tree5, bci.tree6,
         bci.tree7, bci.tree8)
a <- as.data.frame(a)

# sort out years--------
# sort dates
a <- a %>%
  mutate(date=as.Date(date, origin=as.Date("1960-01-01"))) %>%
  mutate(year=format(date,'%Y')) %>%
  select(sp, year, status, treeID, dbh, quadrat,gx,gy) %>%
  rename(species_id=sp, censusyear=year, tree_id=treeID)

# Combine 1981/1982 census years and remove partial census years
censusyear_to_keep <- c(1982, 1985, 1990, 1995,
                        2000, 2005, 2010, 2015)
a <- a %>%
  mutate(censusyear=ifelse(censusyear==1981, 1982,
                           ifelse(censusyear==1982, 1982, censusyear))) %>%
  filter(censusyear %in% censusyear_to_keep) %>%
  arrange(species_id, tree_id, censusyear)

# preliminary filtering -------

# get living trees only
a1 <- subset(a, status=="A")

# Sort out the genus Bactris. There was a change in how individuals
# were counted in 1990 (Feeley et al. 2011).
# To sort this out we give all individuals in the genus Bactris
# new ids so that all individuals in a quadrat are a single individual.
# We give that new, single, individual the mean properties of all
# individuals in that quadrat. Then reconstitute the dataset.
a2 <- read.csv("data/raw/BCI_all_functional_data.csv", header=TRUE)

a3 <- a2 %>%
  select(species_id, genus)

a4 <- merge(a1, a3, by="species_id")

noBac <- a4 %>%
  filter(genus!="Bactris") %>%
  as.data.frame()

Bac <- a4 %>%
  filter(genus=="Bactris") %>%
  mutate(tree_id=paste(species_id,quadrat, sep="_")) %>%
  group_by(tree_id, censusyear, quadrat) %>%
  mutate(dbh=mean(dbh, na.rm=TRUE), gx=mean(gx), gy=mean(gy)) %>%
  arrange(tree_id, censusyear) %>%
  unique() %>%
  as.data.frame()

a5 <- rbind(noBac, Bac)
a5 <- a5 %>%select(-c(genus))

# filter for reproductives ------
# The reproductive size threshold is given by a number obtained
# from Ryan Chisholm called "robin"; reproductives are those
# trees with a dbh>=robin.

# get "robin" data
a6 <- a2 %>%
  select(species_id, genus_species_subspecies, robin) %>%
  mutate(robin=as.numeric(as.character(robin))) %>%
  rename(species=genus_species_subspecies)
a7 <- merge(a5, a6, by.x="species_id")

# filter for reproductives
a7 <- a7 %>%
  mutate(reproductive=ifelse(dbh>=robin, "1", "0")) %>%
  filter(reproductive==1) %>%
  arrange(species, tree_id, censusyear) %>%
  unique()

# get complete table individual x censusyear table
a8 <- a7 %>%
  mutate(present=1) %>%
  pivot_wider(c(tree_id), names_from=censusyear,
              values_from=present, values_fill=0) %>%
  pivot_longer(-c(tree_id), names_to="censusyear",
               values_to="present") %>%
  arrange(tree_id, censusyear)

# get geographic data ------
a9 <- a7 %>%
  select(tree_id, species_id, gx, gy, species) %>%
  group_by(tree_id, species_id, species) %>%
  mutate(gx=mean(gx), gy=mean(gy)) %>%
  unique()

a10 <- merge(a9, a8, by.x="tree_id")

a10 <- a10 %>%
  arrange(species, tree_id, censusyear)

# This df contains reproductives for all quadrants.
saveRDS(a10, "data/processed/bci_reproductives.rds")
