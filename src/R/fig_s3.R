library(tidyverse)
library(cowplot)
library(vegan)

# data
a<-readRDS("data/processed/BCI_allindividuals.rds")

# how many species
length(unique(a$species_id))

d<-a%>%
  filter(N_present>0)%>%
  group_by(censusyear)%>%
  summarize(estimate=length(species_id))

# model
data<-d
m<-lm(estimate~censusyear, data=data)
summary(m)
coef(m)[2]
confint(m)
coef(m)[2]-confint(m)[2,2]
coef(m)[2]-confint(m)[2,1]

# how many years to lose a single species
1/abs(coef(m)[2])

d <- d %>%
  mutate(censusyear=as.numeric(censusyear))
ga <- ggplot(data=d, aes(x=censusyear, y=estimate))+
  geom_point(size=3)+
  geom_smooth(method="lm", se=FALSE)+
  xlab("year")+
  ylab("0D species richness")+
  guides(colour="none")+
  theme_classic()+
  ggtitle("A.")

# fig s3b
# get Simpson's diversity and the effective number of species (Hill numbers 2)

d<-a%>%
  mutate(censusyear=as.numeric(censusyear)) %>%
  group_by(censusyear)%>%
  summarize(D_simpson=diversity(N_present, index = "simpson"))%>%
  mutate(estimate=1/(1-D_simpson))

gb <- ggplot(data=d, aes(x=censusyear, y=estimate))+
  geom_point(size=3)+
  geom_smooth(method="lm", se=FALSE)+
  xlab("year")+
  ylab("2D species evenness")+
  theme_classic()+
  ggtitle("B.")

g <- plot_grid(ga, gb)
save_plot("outputs/fig_s3.pdf", g, nrow = 2, base_width = 50, base_height = 10, units="cm")

