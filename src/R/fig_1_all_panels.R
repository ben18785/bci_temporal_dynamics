# creates all the panels of figure 1 and combines them
library(tidyverse)
library(ggrepel)
library(cowplot)
library(metR)

pal<-c("deepskyblue4", "grey75", "indianred4")

# Fig 1a
b1 <- readRDS("data/processed/fig_1a_data.rds")
ga <- ggplot(data=b1, aes(x=species, y=s_est, ymin=s_LCI, ymax=s_UCI, colour=as.factor(selclass)))+
  geom_errorbar(size=0.25, width=0, alpha=1)+
  geom_point(size=0.25)+
  scale_colour_manual("", values=pal)+
  theme_classic()+
  ylab("s")+
  xlab("species")+
  scale_y_continuous(limits=c(-1.3,0.3), breaks=c(seq(from=-1.25, to=0.5, 0.25)))+
  geom_hline(yintercept=median(b1$s_est), colour="grey25") +
  theme(axis.text.x = element_blank(),axis.ticks.x= element_blank(), legend.position="right")+
  theme(legend.position=c(0.2, 0.2),
        legend.text = element_text(size=14)) +
  ggtitle("A.")

# Fig 1b
df_1b <- readRDS("data/processed/fig_1b_data.rds")
f4 <- df_1b$f4
labels <- df_1b$labels
gb <- ggplot(data=f4, aes(x=as.numeric(censusyear), y=relfreq,
                         colour=as.factor(selclass), group=as.factor(species)))+
  geom_line(size=0.25)+
  geom_point(size=0.25)+
  scale_colour_manual(values=pal)+
  ylab("relative frequency (log10 scale)")+
  xlab("year")+
  guides(fill="none", colour="none")+
  scale_x_continuous(breaks=c(seq(from=1980, to=2015, 5)))+
  scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x)))+
  theme_classic(base_size = 12, base_family = "")+
  theme(axis.line.x = element_line(colour = 'black', size=0.5, linetype='solid'),
        axis.line.y = element_line(colour = 'black', size=0.5, linetype='solid'),
        axis.ticks.x = element_line(colour = 'black', size=0.5), legend.position="right",
        plot.margin = unit(c(0.1, 4, 0.1, 0.1), "cm"))+
  coord_cartesian(clip = "off") +
  geom_text_repel(data=labels,
                  aes(x=as.numeric(censusyear), y=relfreq, label=species),
                  size=2,
                  na.rm = TRUE,
                  force_pull=0, direction = "y",
                  hjust = "left",
                  nudge_x=4,
                  xlim = c(NA, 2030)) +
  ggtitle("B.")

# Fig 1c
# todo: use Armand's geom_contour2 thing
df_1c <- readRDS("data/processed/fig_1c_data.rds")
pred1 <- df_1c$pred1
c2 <- df_1c$c2
labels <- df_1c$labels
breaks <- round(quantile(pred1$w_est), 2)
gc <- ggplot(data=pred1, aes(x=surv_est, y=RR_est, z=w_est))+
  geom_contour2(colour="grey50", bins=50, size=0.1)+
  geom_text_contour(breaks=breaks, colour="grey50", skip=0, size=3, bins=15)+
  geom_point(data=c2, aes(x=surv_est,y=RR_est, colour=as.factor(selclass)), size=2)+
  geom_text_repel(data=labels, aes(x=surv_est, y=RR_est,label=species,colour=as.factor(selclass)), size=2)+
  scale_colour_manual(values=pal)+
  guides(fill="none")+
  xlab("annual probability of survival")+
  ylab("annual relative recruitment")+
  theme_classic()+
  theme(legend.position = "none") +
  ggtitle("C.")

# make grid of plots
g <- plot_grid(ga, gb, gc, nrow = 1)
save_plot("outputs/fig_1.pdf", g, nrow = 1, base_width = 60, base_height = 20, units="cm")
