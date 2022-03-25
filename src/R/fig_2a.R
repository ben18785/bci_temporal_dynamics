# figure 2a species richness: showing the dynamics of species richness in the observed and simulated communities
require(ggplot2)
require(scales)
require(dplyr)
require(data.table)
require(tidyr)


# observed data
a<-readRDS("data/processed/bci_cleaned.rds")

# estimate species richness for each census year.
# This is a simple count of the number of species present.
a1<-a%>%
  group_by(species, censusyear)%>%
  summarize(N_present=sum(N_present))%>%
  filter(N_present>0)%>%
  ungroup%>%
  group_by(censusyear)%>%
  summarize(estimate=length(species))%>%
  mutate(LCI="NA", UCI="NA")%>%
  mutate(dataset="observed")%>%
  as.data.frame()

# birth-death simulations
s<-read.csv("data/processed/exp_1_diversity.csv")
s<-s%>%
  filter(censusyear<=2015)%>%
  select(simulation_nr, censusyear, D_species_richness)%>%
  group_by(censusyear)%>%
  summarize(estimate=quantile(D_species_richness, 0.5),
            LCI=quantile(D_species_richness, 0.025),
            UCI=quantile(D_species_richness, 0.975))%>%
  mutate(dataset="birth-death simulation")%>%
  as.data.frame()

# get the 1982 data for the start of the simulation
first<-a1%>%filter(censusyear==1982)%>%
  mutate(dataset="birth-death simulation")
# combine the data
s5<-rbind(a1, first, s)
s5<-s5%>%
  mutate(LCI=as.numeric(as.character(LCI)), UCI=as.numeric(as.character(UCI)),
         censusyear=as.numeric(as.character(censusyear)))

saveRDS(s5, "data/processed/fig_2a_data.rds")
