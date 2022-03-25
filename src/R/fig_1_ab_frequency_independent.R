# Makes Figures 1A and B showing the distribution of selection coefficients of 258
# species and those estimates combined with frequency dynamics

library(dplyr)
library(data.table)
library(scales)
library(tidyr)
library(broom)

a<-readRDS("data/processed/freq_independent_parameters.rds")
a<-as.data.frame(a)
a<-a%>%
  rename(species=beta.species, beta=beta.value)

# make Figure 1A: distribution of selection coefficients
# get the beta estimates. They are couched in terms of census years
b1<-a%>%
  group_by(species)%>%
  summarise(est=median(beta), LCI=quantile(beta, 0.025), UCI=quantile(beta, 0.975))%>%
  as.data.frame()

# immigration rates (delta): estimated in terms of census years
i<-a%>%
  select(delta)%>%
  summarise(LCI_delta=quantile(delta, 0.025),
            est_delta=median(delta),
            UCI_delta=quantile(delta, 0.975))

# est absolute fitness, W using just the betas. We need an estimate of delta
delta<-i[1,2]

# absolute fitnesses
b1$W_LCI=(1-delta)*(1+b1$LCI)
b1$W_est=(1-delta)*(1+b1$est)
b1$W_UCI=(1-delta)*(1+b1$UCI)

# relative fitnesses
b1$w_LCI=b1$W_LCI/median(b1$W_est)
b1$w_est=b1$W_est/median(b1$W_est)
b1$w_UCI=b1$W_UCI/median(b1$W_est)

# selection coefficients
b1$s_LCI=b1$w_LCI-1
b1$s_est=b1$w_est-1
b1$s_UCI=b1$w_UCI-1

# order
b1<-b1%>%
  arrange(desc(s_est))
b1$order<-1:nrow(b1)
b1$species<-reorder(b1$species, b1$order)

# identify most and least fit species
b1%>%filter(s_est==max(s_est))%>%select(species, s_est)
b1%>%filter(s_est==min(s_est))%>%select(species, s_est)


# colour according to whether *s* is significantly positive or negative
b1$selclass<-ifelse(b1$s_LCI>0, "positive", ifelse(b1$s_UCI<0, "negative", "neutral"))

# how many species have significant selection coefficients by this criterion
sig<-b1%>%
  group_by(selclass)%>%
  summarize(N=length(species))

# export data for fig 1a
saveRDS(b1, "data/processed/fig_1a_data.rds")

# make Figure 2A: selection coefficients mapped onto frequency dynamics of species
f<-readRDS("data/processed/bci_cleaned.rds")

# get frequencies of each species by each census year
f1<-f%>%
  group_by(censusyear)%>%
  mutate(N_total=sum(N_present))%>%
  mutate(freq=N_present/N_total)

# get frequencies relative to first year present
f2<-f1%>%
  filter(N_present>0)%>%
  group_by(species)%>%
  filter(censusyear==min(censusyear))%>%
  select(species, freq)%>%
  rename(startfreq=freq)
f3<-merge(f1, f2)
f3$relfreq<-f3$freq/f3$startfreq
f3$log10relfreq<-log10(f3$relfreq)
f3<-f3%>%
  filter(relfreq>0)

# add in selclass data
b2<-b1%>%
  select(species, s_est, selclass)
f4<-merge(f3, b2, by="species")
f4<-f4%>%
  mutate(censusyear=as.character(as.numeric(censusyear)))

# labels for most highly selected species (significant): 10 postive and 10 negative
labels<-b1%>%
  filter(selclass!="neutral")%>%
  arrange(desc(s_est))%>%
  slice(1:10, 49:59)%>%
  select(species)
f5<-f4%>%
  filter(censusyear==2015)%>%
  select(species, censusyear, relfreq, selclass)
labels<-merge(labels, f5, by="species")
labels<-labels%>%
  select(species, relfreq,censusyear, selclass)%>%
  arrange(desc(relfreq))

# relative frequency plot
saveRDS(list(f4=f4, labels=labels), "data/processed/fig_1b_data.rds")

