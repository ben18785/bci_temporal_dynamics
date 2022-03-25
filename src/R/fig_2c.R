# Makes Figure 2C showing the effect of selection on species richness in the simulated communities.
library(readr)
library(dplyr)
library(data.table)
library(stringr)
library(vegan)
library(broom)
library(tidyr)

# simulation data
# assemble data
a<-read.csv("data/processed/exp_3_diversity.csv")

# get data for 2015 only and rename selection labels.\
# SVt gives the selection due to survival: off/on=0/1\
# BBt gives the selection due to relative recruitment: off/on=0/1\
# We are interested only in the treatments where both are 0 (no selection) or both are 1 (full selection)
a7<-a%>%
  select(-c(X))%>%
  group_by(treatment_label)%>%
  summarize(estimate=quantile(D_species_richness, 0.5),
            LCI=quantile(D_species_richness, 0.025),
            UCI=quantile(D_species_richness, 0.975))%>%
  mutate(dataset="birth-death simulation")%>%
  as.data.frame()

# order
order<-a7%>%
  ungroup()%>%
  select(treatment_label)%>%
  arrange(desc(treatment_label))%>%
  mutate(treatment_order=1:2)
a8<-merge(a7, order, by="treatment_label")
a8$treatment_label<-reorder(a8$treatment_label, a8$treatment_order)

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

saveRDS(list(a8=a8, start=start, end=end), "data/processed/fig_2c_data.rds")
