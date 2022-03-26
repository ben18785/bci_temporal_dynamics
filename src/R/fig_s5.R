# Figure S5: relative change in frequency in the observed and simulated communities
library(tidyverse)

# observed data
a<-readRDS("data/processed/bci_cleaned.rds")

# get frequencies of each species in each census year
a1<-a%>%
  mutate(N_total=sum(N_present))%>%
  mutate(freq=N_present/N_total)

# get the two_point_W = log(F_2015/F1982) for the observed data.
# We need to remove species that are either absent in 1982 or 2015
o<-a1%>%
  arrange(species, censusyear)%>%
  filter(censusyear==1982 | censusyear==2015)%>%
  pivot_wider(-c(species_year, N_born, N_died, N_present, N_total), names_from=censusyear, values_from=freq)%>%
  rename(F_1982="1982", F_2015="2015")%>%
  mutate(W_obs=log(F_2015/F_1982))%>%
  arrange(desc(W_obs))%>%
  filter(F_1982!=0)%>%
  filter(F_2015!=0)%>%
  as.data.frame()

# birth-death simulations
s<-read.csv("data/processed/exp_1_counts.csv")
s<-s%>%
  select(-(X))%>%
  filter(censusyear==2015)%>%
  select(species, freq_est)%>%
  rename(F_2015=freq_est)

start<-o%>%
  select(species, F_1982)
s2<-merge(start, s, by="species")
s2<-s2%>%
  mutate(W_sim=log(F_2015/F_1982))%>%
  arrange(desc(W_sim))%>%
  filter(F_1982!=0)%>%
  filter(F_2015!=0)%>%
  as.data.frame()

# merge the observed and simulated two-point fitnesses
o1<-o%>%
  select(species, W_obs)
s3<-s2%>%
  select(species, W_sim)
s4<-merge(o1, s3, by="species")

# plot
g <- ggplot(data=s4, aes(x=W_obs, y=W_sim))+
  geom_point(size=2, colour="grey50")+
  xlim(-5, 3)+
  ylim(-5,3)+
  xlab("observed two-point W")+
  ylab("simulated two-point W")+
  theme_classic()+
  geom_smooth(method="lm", se=FALSE, colour="blue")+
  theme(aspect.ratio = 1)

ggsave("outputs/fig_s5.pdf", g, width = 12, height = 8)

# linear model
m<-lm(W_sim~W_obs, data=s4)
summary(m)
summary(m)
coef(m)[2]
confint(m)
coef(m)[2]-confint(m)[2,2]
coef(m)[2]-confint(m)[2,1]
