# Fig s6: two most abundany
library(tidyverse)

s<-read.csv("data/processed/exp_1_most_abundant.csv")
s<-s%>%
  mutate(projectedyear=censusyear-2015)

# examine the frequency dynamics of the two species that will be most abundant in 2498
pal<-c("deepskyblue4", "grey75", "indianred4")
g <- ggplot(data=s, aes(x=projectedyear, y=est, ymin=LCI, ymax=UCI, colour=as.factor(species), fill=as.factor(species)))+
  geom_line()+
  geom_ribbon(alpha=0.5, colour="NA")+
  scale_colour_manual("", values=pal) +
  scale_fill_manual("", values=pal) +
  ylab("frequency")+
  theme_classic()+
  theme(aspect.ratio = 1) +
  xlab("projected year")

ggsave("outputs/fig_s6.pdf", g, width = 12, height = 8)
