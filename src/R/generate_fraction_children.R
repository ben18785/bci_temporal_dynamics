# exports N_trees and fraction of children... this file was transcribed by Ben from Jeronimo's file
require(scales)
require(dplyr)
require(stringr)
require(data.table)
require(tidyr)

counts <- readRDS("data/processed/bci_cleaned.rds") %>%
  select(species, censusyear, N_present)

# ascertain any lazarus species have been removed: these species aren´t present in 1982 so can´t oscillate.
counts <- counts %>% filter(str_detect(species, pattern = "_2", negate = TRUE)) %>%
  filter(str_detect(species, pattern = "_3", negate = TRUE))
counts <- counts %>% filter(str_detect(species, pattern = "_", negate = TRUE))

# remove x0 = 0: these species can't evolve from a frequency of 0.
sp_absent_1982 <- counts %>%
  filter(censusyear == 1982) %>%
  filter(N_present == 0) %>%
  select(species)
DF1 <- counts %>% filter(species!="Cupania latifolia")%>%
  filter(species != "Hamelia patens" )%>%
  filter(species != "Ternstroemia tepezapote" )%>%
  filter(species != "Cedrela odorata" )%>%
  filter(species != "Trema micrantha" )%>%
  filter(species != "Cojoba rufescens" )

# transform to frequency
DF1 <- DF1 %>%
  group_by(censusyear) %>%
  mutate(freq = N_present/sum(N_present))
sum(DF1$freq) # should be 8
test1 <- DF1 %>% filter(censusyear==1982)
sum(test1$freq) # should be 1

# obtain population sizes per census year
N_total_summary_table <- DF1 %>%
  group_by(censusyear) %>%
  summarise(N_total_censusyear = sum(N_present), .groups = 'drop')

# export N_trees_summary_table
write.csv(N_total_summary_table,
          file="data/processed/N_trees.csv",
          row.names = FALSE)

# calculate average offspring per generation in real data
b <- readRDS("data/processed/bci_cleaned.rds")
b1<- b %>%
  select(censusyear, N_present)%>%
  group_by(censusyear)%>%
  summarize(N_total=sum(N_present))%>%
  as.data.frame()

b2 <- b%>%
  select(censusyear, N_born)%>%
  group_by(censusyear)%>%
  summarize(N_born=sum(N_born))%>%
  as.data.frame()

b3<- b1 %>%
  filter(censusyear!=2015)%>%
  rename(N_parents=N_total)
b3$censusyear<-c(1985,1990,1995,2000,2005,2010,2015)

b4 <- merge(b3, b2, by="censusyear")
b4 <-b4 %>%
  mutate(fraction_born=N_born/N_parents)

write.csv(b4, "data/processed/fraction_children_born_censusyear.csv", row.names = FALSE)
