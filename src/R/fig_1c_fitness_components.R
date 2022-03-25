# explaining fitness in terms of fitness components

library(dplyr)
library(ggplot2)
library(tidyr)
library(mgcv)

b<-readRDS("data/processed/birth_death_estimates.rds")
g<-readRDS("data/processed/stan_fits/overall_freq_independent.rds")
s<-readRDS("data/processed/reproductives_stan_birth_death_data.rds")
species<-as.character(s$ordering$species)

# get relative recruitment ------
# get the fitness, due to birth-beta, of each species. RR = k * (1 − delta) * (1 + birth_beta_i).  We will call this **relative recruitment**.
# convert the birth betas to annual rates and then summarize
censusyears<-c(1982, 1985, 1990, 1995, 2000, 2005, 2010, 2015)
diffcensusyears<-diff(censusyears)
meandiffcensusyears<-mean(diffcensusyears)
meandiffcensusyears

b1<-b%>%
  rename(species=name, birth_beta=beta)%>%
  mutate(birth_beta=birth_beta/meandiffcensusyears)%>%
  group_by(species)%>%
  summarise(bb_LCI=quantile(birth_beta, 0.025), bb_est=median(birth_beta), bb_UCI=quantile(birth_beta, 0.975))%>%
  as.data.frame()

# To get the RR we need the immigration rates (delta): estimated in terms of census years
i<-g%>%
  as.data.frame()%>%
  select(delta)%>%
  summarise(LCI_delta=quantile(delta, 0.025), est_delta=median(delta), UCI_delta=quantile(delta, 0.975))
delta<-i[1,2]

b1<-b1%>%
  mutate(RR_LCI=(1-delta)*(1+bb_LCI))%>%
  mutate(RR_est=(1-delta)*(1+bb_est))%>%
  mutate(RR_UCI=(1-delta)*(1+bb_UCI))
b1<-b1%>%
  select(species, RR_LCI, RR_est, RR_UCI)%>%
  arrange(desc(RR_est))

# get the survivorships
# summarize. These are already annual
s1<-b%>%
  rename(species=name)%>%
  group_by(species)%>%
  summarise(surv_LCI=quantile(p_survive_annual, 0.025), surv_est=median(p_survive_annual), surv_UCI=quantile(p_survive_annual, 0.975))%>%
  as.data.frame()

# get the global fitnesses
# get the global beta estimates. They are couched in terms of census years, so first make them annual.
g1<-g%>%
  as.data.frame()%>%
  select("beta[1]":"beta[258]")%>%
  mutate(run=1:1600)%>%
  pivot_longer(-(run), names_to="beta_id", values_to="beta")%>%
  mutate(beta_id=gsub("beta", "", beta_id))%>%
  mutate(beta_id=gsub("\\[", "", beta_id))%>%
  mutate(beta_id=gsub("\\]", "", beta_id))%>%
  mutate(beta_id=as.numeric(beta_id))%>%
  arrange(beta_id)%>%
  group_by(beta_id)%>%
  mutate(beta=beta/meandiffcensusyears)%>% # standardize by years
  summarise(g_est=median(beta), g_LCI=quantile(beta, 0.025), g_UCI=quantile(beta, 0.975))%>%
  as.data.frame()

# add species names
species<-as.character(s$ordering$species)
g1$species<-species

# est absolute fitness
g1$W_LCI=(1-delta)*(1+g1$g_LCI)
g1$W_est=(1-delta)*(1+g1$g_est)
g1$W_UCI=(1-delta)*(1+g1$g_UCI)

# relative fitnesses
g1$w_LCI=g1$W_LCI/median(g1$W_est)
g1$w_est=g1$W_est/median(g1$W_est)
g1$w_UCI=g1$W_UCI/median(g1$W_est)

# selection coefficients and colour according to whether selection is positive, neutral or negative
g1$s_LCI=g1$w_LCI-1
g1$s_est=g1$w_est-1
g1$s_UCI=g1$w_UCI-1
g1$selclass<-ifelse(g1$s_LCI>0, "positive", ifelse(g1$s_UCI<0, "negative", "neutral"))
g1<-g1%>%select(species, w_LCI, w_est, w_UCI, selclass)

# combine data frames
# merge the dataframes
c1<-merge(b1,s1, by="species")
c2<-merge(c1,g1, by="species")

# size of data
dim(c1)
dim(c2)

# identify extreme species

##### RR
# identify the species that have the highest and lowest relative recruitment (RR_est)

c2%>%filter(RR_est==max(RR_est))%>%
  dplyr::select(species, RR_LCI, RR_est,RR_UCI)%>%
  mutate(RR_est=round(RR_est,3),RR_LCI=round(RR_LCI,3), RR_UCI=round(RR_UCI,3))

c2%>%filter(RR_est==min(RR_est))%>%
  dplyr::select(species, RR_LCI, RR_est,RR_UCI)%>%
  mutate(RR_est=round(RR_est,3),RR_LCI=round(RR_LCI,3), RR_UCI=round(RR_UCI,3))


# survivorship -------
# identify the species that have the highest and lowest survivorhip
c2%>%filter(surv_est==max(surv_est))%>%
  dplyr::select(species, surv_LCI,surv_est, surv_UCI)%>%
  mutate(surv_LCI=round(surv_LCI, 3),
         surv_est=round(surv_est, 3),
         surv_UCI=round(surv_UCI, 3))

c2%>%filter(surv_est==min(surv_est))%>%
  dplyr::select(species, surv_LCI,surv_est, surv_UCI)%>%
  mutate(surv_LCI=round(surv_LCI, 3),
         surv_est=round(surv_est, 3),
         surv_UCI=round(surv_UCI, 3))

##### global relative fitness
# identify the species that have the highest and lowest global relative fitness
c2%>%filter(w_est==max(w_est))%>%
  dplyr::select(species, w_LCI,w_est, w_UCI)%>%
  mutate(w_LCI=round(w_LCI, 3),
         w_est=round(w_est, 3),
         w_UCI=round(w_UCI, 3))

c2%>%filter(w_est==min(w_est))%>%
  dplyr::select(species, w_LCI,w_est, w_UCI)%>%
  mutate(w_LCI=round(w_LCI, 3),
         w_est=round(w_est, 3),
         w_UCI=round(w_UCI, 3))

# make a fitness surface
# Get the fitness surface using w_est as the independent variable and estimate it using a gam
m12<-gam(w_est~s(surv_est)+(RR_est), data=c2)
summary(m12)

# Together, they explain 75% of the variance. predict the gam
surv_est<-seq(from=min(c2$surv_est),to=max(c2$surv_est), length.out = 250)
RR_est<-seq(from=min(c2$RR_est),to=max(c2$RR_est), length.out = 250)
pred1<-expand.grid(surv_est,RR_est)
names(pred1)<-c("surv_est", "RR_est")
pred1$w_est<-predict(m12, newdata=pred1)
mean(pred1$w_est)

# get labels
labels<-c2%>%
  filter(selclass!="neutral")%>%
  arrange(desc(w_est))%>%
  slice(1:10, 49:59)

# save data for plot
saveRDS(list(pred1=pred1, c2=c2, labels=labels), "data/processed/fig_1c_data.rds")
