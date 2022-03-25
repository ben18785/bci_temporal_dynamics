# Get data for all species including juveniles and lazarus species
library(lubridate)
library(stringr)
library(tidyverse)

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
a<-rbind(bci.tree1, bci.tree2, bci.tree3, bci.tree4, bci.tree5, bci.tree6, bci.tree7, bci.tree8)
a<-as.data.frame(a)

# sort out years
# sort dates
a<-a%>%
  mutate(date=as.Date(date, origin=as.Date("1960-01-01")))%>%
  mutate(year=format(date,'%Y'))%>%
  select(sp, year, status, treeID, dbh, quadrat,gx,gy)%>%
  rename(species_id=sp, censusyear=year, tree_id=treeID)

# Combine 1981/1982 census years and remove partial census years
a<-a%>%
  mutate(censusyear=ifelse(censusyear==1981, 1982, ifelse(censusyear==1982, 1982, censusyear)))%>%
  filter(censusyear==1982| censusyear==1985| censusyear==1990| censusyear==1995| censusyear==2000|   censusyear==2005| censusyear==2010| censusyear==2015)%>%
  arrange(species_id,tree_id,censusyear)


# preliminary filtering
# get living trees only
a1<-subset(a, status=="A")

# Sort out the genus Bactris.
# There was a change in how individuals were counted in 1990 (Feeley et al. 2011).
# To sort this out we give all individuals in the genus Bactris new ids so that all
# individuals in a quadrat are a single individual. We give that new, single, individual
# the mean properties of all individuals in that quadrat. Then reconstitute the dataset.
a2<-read.csv("data/raw/BCI_all_functional_data.csv", header=TRUE)
a3<-a2%>%
  select(species_id, genus)
a4<-merge(a1, a3, by="species_id")
noBac<-a4%>%
  filter(genus!="Bactris")%>%
  as.data.frame()
Bac<-a4%>%
  filter(genus=="Bactris")%>%
  mutate(tree_id=paste(species_id,quadrat, sep="_"))%>%
  group_by(tree_id, censusyear, quadrat)%>%
  mutate(dbh=mean(dbh, na.rm=TRUE), gx=mean(gx), gy=mean(gy))%>%
  arrange(tree_id, censusyear)%>%
  unique()%>%
  as.data.frame()
a5<-rbind(noBac, Bac)
a5<-a5%>%select(-c(genus))

# get complete table individual x censusyear table
a6<-a5%>%
  mutate(present=1)%>%
  pivot_wider(c(tree_id), names_from=censusyear, values_from=present, values_fill=0)%>%
  pivot_longer(-c(tree_id), names_to="censusyear", values_to="present")%>%
  arrange(tree_id, censusyear)

# re-associate species_ids with tree ids
sp<-a5%>%
  select(species_id, tree_id)%>%
  unique()
a7<-merge(a6, sp, by="tree_id")

# summarize by species
a8<-a7%>%
  group_by(species_id, censusyear)%>%
  summarize(N_present=sum(present))%>%
  ungroup()%>%
  group_by(censusyear)%>%
  mutate(N_total=sum(N_present))%>%
  mutate(freq=N_present/N_total)

saveRDS(a8, "data/processed/BCI_allindividuals.rds")

