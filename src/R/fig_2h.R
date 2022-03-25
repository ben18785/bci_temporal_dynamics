# Makes Figure 2H showing the dynamics of species evenness in the simulated communities over the long term
require(scales)
require(dplyr)
require(data.table)
require(vegan)
require(tidyr)

# observed data
a<-readRDS("data/processed/bci_cleaned.rds")

# Simpson's diversity and the effective number of species (Hill 2) calculated from it
a1<-a%>%
  group_by(censusyear)%>%
  summarize(D_simpson=diversity(N_present, index = "simpson"))%>%
  mutate(estimate=1/(1-D_simpson))%>%
  select(-c(D_simpson))%>%
  mutate(LCI="NA", UCI="NA")%>%
  mutate(dataset="observed")%>%
  as.data.frame()

# birth-death simulations
s<-read.csv("data/processed/exp_2_diversity.csv")
s1<-s%>%
  select(simulation_nr, censusyear,H_simpson)%>%
  group_by(censusyear)%>%
  summarize(estimate=quantile(H_simpson, 0.5),
  LCI=quantile(H_simpson, 0.025),
  UCI=quantile(H_simpson, 0.975))%>%
  mutate(dataset="birth-death simulation")

# get the 1982 data for the start of the simulation
first<-a1%>%filter(censusyear==2015)%>%
  mutate(dataset="birth-death simulation")
s2<-rbind(a1, first, s1)
s2<-s2%>%
  mutate(LCI=as.numeric(as.character(LCI)), UCI=as.numeric(as.character(UCI)),
         censusyear=as.numeric(as.character(censusyear)))%>%
  mutate(projectedyear=censusyear-2015)%>%
  mutate(projectedyear=censusyear-2015)

saveRDS(s2, "data/processed/fig_2h_data.rds")
