# produces fig 2b: showing the dynamics of species evenness in the observed and simulated communities
require(ggplot2)
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
s<-read.csv("data/processed/exp_1_diversity.csv")
s<-s%>%
  filter(censusyear<=2015)%>%
  select(simulation_nr, censusyear, H_simpson)%>%
  group_by(censusyear)%>%
  summarize(estimate=quantile(H_simpson, 0.5),
  LCI=quantile(H_simpson, 0.025),
  UCI=quantile(H_simpson, 0.975))%>%
  mutate(dataset="birth-death simulation")%>%
  as.data.frame()

# get the 1982 data for the start of the simulation
first<-a1%>%filter(censusyear==1982)%>%
  mutate(dataset="birth-death simulation")
s5<-rbind(a1, first, s)
s5<-s5%>%
  mutate(LCI=as.numeric(as.character(LCI)),
         UCI=as.numeric(as.character(UCI)),
         censusyear=as.numeric(as.character(censusyear)))

saveRDS(s5, "data/processed/fig_2b_data.rds")

