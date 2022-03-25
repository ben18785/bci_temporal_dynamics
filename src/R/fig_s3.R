library(tidyverse)

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
g <- ggplot(data=d, aes(x=censusyear, y=estimate))+
  geom_point(size=3)+
  geom_smooth(method="lm", se=FALSE)+
  xlab("year")+
  ylab("0D species richness")+
  guides(colour="none")+
  theme_classic()+
  theme(aspect.ratio = 1)

ggsave("outputs/fig_s3.pdf", g, width = 12, height = 8)


