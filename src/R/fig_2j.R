# Makes Figure 2J showing the effect of immigration on species evenness in the simulated communities.
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
  summarize(estimate=quantile(H_simpson, 0.5),
            LCI=quantile(H_simpson, 0.025),
            UCI=quantile(H_simpson, 0.975))%>%
  mutate(dataset="birth-death simulation")%>%
  mutate(projectedyear=censusyear-2015)%>%
  as.data.frame()

# observed species evenness for 1982 and 2015
b<-readRDS("data/processed/bci_cleaned.rds")

# get species evenness for the observed data
b1<-b%>%
  group_by(censusyear)%>%
  summarize(D_simpson=diversity(N_present, index = "simpson"))%>%
  mutate(estimate=1/(1-D_simpson))%>%
  select(-c(D_simpson))%>%
  mutate(LCI="NA", UCI="NA")%>%
  mutate(dataset="observed")

# lines for 1982 and 2015
start<-b1%>%filter(censusyear=="1982")
start<-start$estimate
end<-b1%>%filter(censusyear=="2015")
end<-end$estimate

saveRDS(list(a5=a5, start=start, end=end), "data/processed/fig_2j_data.rds")
