# Makes turnover of BCI individuals figure
library(ggplot2)
library(lubridate)
library(scales)
library(dplyr)
library(tidyr)

# get data
a<-readRDS("data/processed/bci_cleaned.rds")

# get N_present by year
p<-a%>%
  group_by(censusyear)%>%
  summarize(N=sum(N_present))%>%
  mutate(statistic="N_total")

# get N_born by year
b<-a%>%
  group_by(censusyear)%>%
  summarize(N=sum(N_born))%>%
  filter(censusyear>1982)%>%
  mutate(statistic="N_born")

# get N_died by year
d<-a%>%
  group_by(censusyear)%>%
  summarize(N=sum(N_died))%>%
  mutate(statistic="N_died")

# combine
c<-rbind(p, b, d)
c<-c%>%
  mutate(censusyear=as.numeric(as.character(censusyear)))

# model N_total

a5<-c%>%
  filter(statistic=="N_total")
censusyear2<-a5$censusyear^2
m1<-lm(N~censusyear, data=a5)
summary(m1)
m2<-lm(N~censusyear+censusyear2, data=a5)
summary(m2)
anova(m1, m2)
BIC(m1, m2)
censusyear<-a5$censusyear
pred_N_total<-as.data.frame(censusyear)
pred_N_total$fit<-predict(m1, pred_N_total,  se.fit = TRUE)$fit
pred_N_total$se<-predict(m1, pred_N_total,  se.fit = TRUE)$se.fit
pred_N_total$statistic<-"N_total"

coef(m1)[2]
confint(m1)[2,2]-coef(m1)[2]
confint(m1)[2,1]-coef(m1)[2]

# model N_born
a5<-c%>%
  filter(statistic=="N_born")
censusyear2<-a5$censusyear^2
m1<-lm(N~censusyear, data=a5)
summary(m1)
m2<-lm(N~censusyear+censusyear2, data=a5)
summary(m2)
anova(m1, m2)
BIC(m1, m2)
censusyear<-a5$censusyear
pred_N_born<-as.data.frame(censusyear)
pred_N_born$censusyear2<-censusyear2
pred_N_born$fit<-predict(m2, pred_N_born,  se.fit = TRUE)$fit
pred_N_born$se<-predict(m2, pred_N_born,  se.fit = TRUE)$se.fit
pred_N_born$statistic<-"N_born"

# model N_died
a5<-c%>%
  filter(statistic=="N_died")
censusyear2<-a5$censusyear^2
m1<-lm(N~censusyear, data=a5)
summary(m1)
m2<-lm(N~censusyear+censusyear2, data=a5)
summary(m2)
anova(m1, m2)
BIC(m1, m2)
censusyear<-a5$censusyear
pred_N_died<-as.data.frame(censusyear)
pred_N_died$censusyear2<-censusyear2
pred_N_died$fit<-predict(m2, pred_N_died,  se.fit = TRUE)$fit
pred_N_died$se<-predict(m2, pred_N_died,  se.fit = TRUE)$se.fit
pred_N_died$statistic<-"N_died"

# get predicted data in one dataframe
pred_N_died<-pred_N_died%>%
  select(-c(censusyear2))
pred_N_born<-pred_N_born%>%
  select(-c(censusyear2))
predall<-rbind(pred_N_total, pred_N_born, pred_N_died)

# plot
pal<-c("lightsteelblue4", "indianred4", "darkolivegreen4")
g <- ggplot()+
  geom_point(data=c, aes(x=censusyear, y=N, colour=as.factor(statistic)), size=3)+
  theme_classic()+
  scale_colour_manual("", values=pal)+
  scale_fill_manual("", values=pal)+
  scale_y_continuous(limits=c(0,100000), breaks=seq(from=0, to=250000, 10000))+
  ylab("N individuals")+
  xlab("year")+
  theme(aspect.ratio = 1)+
  scale_x_continuous(limits=c(1980, 2018), breaks=c(seq(from=1980, to=2015, 5)))+
  theme(aspect.ratio=1)+
  geom_line(data=predall, aes(x=censusyear, y=fit, colour=as.factor(statistic)), size=1)+
  geom_ribbon(data=predall, aes(x=censusyear, y=fit, ymin=fit-se,
                                ymax=fit+se, fill=as.factor(statistic)), size=1, alpha=0.5)

ggsave("outputs/fig_s1.pdf", g, width = 12, height = 8)
