# Figure S4 frequency dynamics of abundant species in the observed and simulated communities
library(tidyverse)

# get the observed data
o<-readRDS("data/processed/bci_cleaned.rds")

# get frequencies of each species in each census year
o1<-o%>%
  group_by(censusyear)%>%
  mutate(N_total=sum(N_present))%>%
  mutate(freq_est=N_present/N_total)

# filter out species not present in 1982
remove<-o1%>%
  filter(censusyear=="1982" & N_present==0)
remove<-remove$species
o1<-o1%>%filter(!species%in%remove)%>%
  select(species, censusyear, freq_est)%>%
  mutate(freq_LCI=as.numeric("NA"), freq_UCI=as.numeric("NA"))

# get the simulated data
# get data
s<-read.csv("data/processed/exp_1_counts.csv")%>%
  select(-c(X))

# add in 1982 data to the simulations (from the observed)
s2<-o1%>%filter(censusyear=="1982")
s2<-as.data.frame(s2)
s1<-as.data.frame(s)
s3<-rbind(s1, s2)
s3<-s3%>%arrange(species, censusyear)%>%
  mutate(freq_LCI=as.numeric(freq_LCI), freq_UCI=as.numeric(freq_UCI))

# combine observed and simulated data
o1<-o1%>%mutate(dataset="observed")%>%as.data.frame()
s3<-s3%>%mutate(dataset="simulated")%>%as.data.frame()
c<-rbind(o1, s3)

# order species by frequency and filter for the 9 most abundant species
order<-c%>%
  filter(dataset=="observed")%>%
  group_by(species)%>%
  summarize(mean_freq=mean(freq_est))%>%
  arrange(desc(mean_freq))%>%
  mutate(species_order=1:length(species))%>%
  slice(1:9)%>%
  select(species, species_order)
c1<-merge(c, order, by="species")
c1<-c1%>%arrange(dataset, species_order, censusyear)%>%
  mutate(censusyear=as.numeric(censusyear))
c1$species<-reorder(c1$species, as.numeric(c1$species_order))

# plot
pal<-c("darkgreen", "grey50")
g <- ggplot(c1, aes(x=censusyear, y=freq_est, ymin=freq_LCI, ymax=freq_UCI,fill=as.factor(dataset), colour=as.factor(dataset)))+
  geom_point(size=3)+
  geom_line(size=1)+
  scale_color_manual("", values=pal)+
  scale_fill_manual("", values=pal)+
  geom_ribbon(alpha=0.5, colour="NA")+
  ylab("frequency")+
  xlab("year")+
  facet_wrap(~species, ncol=3, scales="free_y")+
  theme_classic()+
  theme(aspect.ratio = 1)

ggsave("outputs/fig_s4.pdf", g, width = 12, height = 8)
