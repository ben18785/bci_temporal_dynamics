# Makes Figure 2I showing the effect of immigration on species richness in the simulated communities.
library(readr)
library(dplyr)
library(data.table)
library(stringr)
library(vegan)
library(broom)
library(tidyr)


# simulation data
a<-read.csv("data/processed/exp_2_diversity.csv")

# summarize by migration rate, Mt
a5<-a%>%
  group_by(Mt, censusyear)%>%
  summarize(estimate=quantile(D_species_richness, 0.5),
            LCI=quantile(D_species_richness, 0.025),
            UCI=quantile(D_species_richness, 0.975))%>%
  mutate(dataset="birth-death simulation")%>%
  mutate(projectedyear=censusyear-2015)%>%
  as.data.frame()

# get the observed species richness for 1982 and 2015
b<-readRDS("data/processed/bci_cleaned.rds")

# get species richness for the observed data
b1<-b%>%
  group_by(species, censusyear)%>%
  summarize(N_present=sum(N_present))%>%
  filter(N_present>0)%>%
  ungroup%>%
  group_by(censusyear)%>%
  summarize(estimate=length(species))%>%
  mutate(LCI="NA", UCI="NA")%>%
  mutate(dataset="observed")%>%
  as.data.frame()

# lines for 1982 and 2015
start<-b1%>%filter(censusyear=="1982")
start<-start$estimate
end<-b1%>%filter(censusyear=="2015")
end<-end$estimate

saveRDS(list(a5=a5, start=start, end=end), "data/processed/fig_2i_data.rds")

