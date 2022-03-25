library(tidyverse)

a<-readRDS("data/processed/quartered_betas.rds")

# This function rearranges the data
gatherpairs <- function(data, ...,
                        xkey = '.xkey', xvalue = '.xvalue',
                        ykey = '.ykey', yvalue = '.yvalue',
                        na.rm = FALSE, convert = FALSE, factor_key = FALSE) {
  vars <- quos(...)
  xkey <- enquo(xkey)
  xvalue <- enquo(xvalue)
  ykey <- enquo(ykey)
  yvalue <- enquo(yvalue)

  data %>% {
    cbind(gather(., key = !!xkey, value = !!xvalue, !!!vars,
                 na.rm = na.rm, convert = convert, factor_key = factor_key),
          select(., !!!vars))
  } %>% gather(., key = !!ykey, value = !!yvalue, !!!vars,
               na.rm = na.rm, convert = convert, factor_key = factor_key)
}

# run function
a3<-a%>%
  gatherpairs(NE, NW, SE, SW)

# get the selection classes (as in Figure 1A: code is compacted here.)
b<-readRDS("data/processed/freq_independent_parameters.rds")
b<-as.data.frame(b)
b<-b%>%
  rename(species=beta.species, beta=beta.value)
b1<-b%>%
  group_by(species)%>%
  summarise(est=median(beta), LCI=quantile(beta, 0.025), UCI=quantile(beta, 0.975))%>%
  as.data.frame()
i<-b%>%
  select(delta)%>%
  summarise(LCI_delta=quantile(delta, 0.025), est_delta=median(delta), UCI_delta=quantile(delta, 0.975))
delta<-i[1,2]
b1$W_LCI=(1-delta)*(1+b1$LCI)
b1$W_est=(1-delta)*(1+b1$est)
b1$W_UCI=(1-delta)*(1+b1$UCI)
b1$w_LCI=b1$W_LCI/median(b1$W_est)
b1$w_est=b1$W_est/median(b1$W_est)
b1$w_UCI=b1$W_UCI/median(b1$W_est)
b1$s_LCI=b1$w_LCI-1
b1$s_est=b1$w_est-1
b1$s_UCI=b1$w_UCI-1
b1<-b1%>%
  arrange(desc(s_est))
b1$order<-1:nrow(b1)
b1$species<-reorder(b1$species, b1$order)
b1$selclass<-ifelse(b1$s_LCI>0, "positive", ifelse(b1$s_UCI<0, "negative", "neutral"))
b1<-b1%>%select(species, selclass)

# combine data
a4<-merge(a3, b1, by="species")

pal<-c("deepskyblue4", "grey75", "indianred4")
g <- ggplot(a4, aes(x = .xvalue, y = .yvalue, colour=as.factor(selclass))) +
  geom_point(size=0.5) +
  facet_grid(.xkey ~ .ykey)+
  scale_colour_manual("", values=pal)+
  theme_classic()+
  xlab("beta")+
  ylab("beta")+
  theme(aspect.ratio=1)

ggsave("outputs/fig_s2.pdf", g, width = 12, height = 8)

