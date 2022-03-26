library(tidyverse)
library(cowplot)

pal<-c("grey50", "darkgreen")

# fig 2a
s5 <- readRDS("data/processed/fig_2a_data.rds")
ga <- ggplot(data=s5, aes(x=censusyear, y=estimate, ymin=LCI, ymax=UCI, colour=as.factor(dataset)))+
  geom_point(size=3)+
  geom_errorbar(size=1, width=1)+
  scale_color_manual(values=pal)+
  geom_smooth(method="lm", se=FALSE, size=1)+
  xlab("year")+
  ylab("0D species richness")+
  guides(colour=FALSE)+
  theme_classic()+
  ggtitle("A.")

# fig 2b
s5 <- readRDS("data/processed/fig_2b_data.rds")
gb <- ggplot(data=s5, aes(x=censusyear, y=estimate, ymin=LCI,
                          ymax=UCI, colour=as.factor(dataset)))+
  geom_point(size=3)+
  geom_errorbar(size=1, width=1)+
  scale_color_manual(values=pal)+
  geom_smooth(method="lm", se=FALSE, size=1)+
  xlab("year")+
  ylab("2D species evenness")+
  guides(colour="none")+
  theme_classic()+
  ylim(4,7) +
  ggtitle("B.")

# fig 2c
temp <- readRDS("data/processed/fig_2c_data.rds")
a8 <- temp$a8
start <- temp$start
end <- temp$end
gc <- ggplot(a8, aes(x=treatment_label, y=estimate, ymin=LCI, ymax=UCI))+
  geom_hline(yintercept=start, colour="darkgreen", size=1)+
  geom_hline(yintercept=end, colour="darkgreen", linetype="dashed", size=1)+
  geom_point(stat="identity", size=3, colour="grey50")+
  geom_errorbar(width=0.1, colour="grey50")+
  ylab("species richness")+
  xlab("treatment")+
  ylim(220, 265)+
  theme_classic()+
  ggtitle("C.")

# fig 2d
temp <- readRDS("data/processed/fig_2d_data.rds")
a8 <- temp$a8
start <- temp$start
end <- temp$end
gd <- ggplot(a8, aes(x=treatment_label, y=estimate, ymin=LCI, ymax=UCI))+
  geom_hline(yintercept=start, colour="darkgreen", size=1)+
  geom_hline(yintercept=end, colour="darkgreen", linetype="dashed", size=1)+
  geom_point(stat="identity", size=3, colour="grey50")+
  geom_errorbar(width=0.1, colour="grey50")+
  ylab("species evenness")+
  xlab("treatment")+
  ylim(4,7)+
  theme_classic()+
  ggtitle("D.")

# fig 2e
temp <- readRDS("data/processed/fig_2e_data.rds")
a8 <- temp$a8
start <- temp$start
end <- temp$end
ge <- ggplot(a8, aes(x=log10(censussize), y=estimate, ymin=LCI, ymax=UCI))+
  geom_hline(yintercept=start, colour="darkgreen", size=1)+
  geom_hline(yintercept=end, colour="darkgreen", linetype="dashed", size=1)+
  geom_point(stat="identity", size=3, colour="grey50")+
  geom_errorbar(width=0.1, colour="grey50")+
  ylab("species richness")+
  xlab("log10(census population size, N)")+
  ylim(220,265)+
  theme_classic()+
  theme(axis.text.x = element_text(size=10)) +
  ggtitle("E.")

# fig 2f
#### plot
temp <- readRDS("data/processed/fig_2f_data.rds")
a8 <- temp$a8
start <- temp$start
end <- temp$end
gf <- ggplot(a8, aes(x=log10(censussize), y=estimate, ymin=LCI, ymax=UCI))+
  geom_hline(yintercept=start, colour="darkgreen", size=1)+
  geom_hline(yintercept=end, colour="darkgreen", linetype="dashed", size=1)+
  geom_point(stat="identity", size=3, colour="grey50")+
  geom_errorbar(width=0.1, colour="grey50")+
  ylab("species evenness")+
  xlab("log10(census population size, N)")+
  ylim(4,7)+
  theme_classic()+
  theme(axis.text.x = element_text(size=10)) +
  ggtitle("F.")

# fig 2g
s2 <- readRDS("data/processed/fig_2g_data.rds")
gg <- ggplot(data=s2, aes(x=projectedyear, y=estimate, ymin=LCI, ymax=UCI,
                    colour=as.factor(dataset), fill=as.factor(dataset)))+
  geom_line(size=1)+
  geom_ribbon(size=1, alpha=0.5, colour="NA")+
  geom_hline(yintercept=1, linetype="dotted", colour="black")+
  scale_color_manual(values=pal)+
  scale_fill_manual(values=pal)+
  xlab("year")+
  ylab("0D species richness")+
  guides(colour="none", fill="none")+
  theme_classic()+
  ylim(0,300) +
  ggtitle("G.")

# fig 2h
s2 <- readRDS("data/processed/fig_2h_data.rds")
gh <- ggplot(data=s2, aes(x=projectedyear, y=estimate, ymin=LCI, ymax=UCI,
                    colour=as.factor(dataset), fill=as.factor(dataset)))+
  geom_line(size=1)+
  geom_ribbon(size=1, alpha=0.5, colour="NA")+
  geom_hline(yintercept=1, linetype="dotted", colour="black")+
  scale_color_manual(values=pal)+
  scale_fill_manual(values=pal)+
  xlab("year")+
  ylab("2D species evenness")+
  guides(colour="none", fill="none")+
  theme_classic()+
  ggtitle("H.")

# fig 2i
pal_i<-gray.colors(10, start = 0.3, end = 0.9, gamma = 2.2)
temp <- readRDS("data/processed/fig_2i_data.rds")
a5 <- temp$a5
start <- temp$start
end <- temp$end


labels <- map_chr(2^seq(0, 5, 1), ~paste0(., "X"))
gi <- ggplot()+
  geom_line(data=a5, aes(x=projectedyear, y=estimate,
                         group=as.factor(Mt), colour=as.factor(Mt)), size=1)+
  scale_colour_manual("", values=pal_i,
                      labels=labels)+
  geom_hline(yintercept=start, colour="darkgreen")+
  geom_hline(yintercept=end, colour="darkgreen", linetype="dotted")+
  geom_hline(yintercept=1, colour="black", linetype="dashed")+
  xlim(0, 1000)+
  xlab("year")+
  ylab("species richness")+
  theme_classic() +
  ggtitle("I.")

# fig 2j
pal_j<-gray.colors(8, start = 0.3, end = 0.9, gamma = 2.2)
temp <- readRDS("data/processed/fig_2j_data.rds")
a5 <- temp$a5
start <- temp$start
end <- temp$end
gj <- ggplot()+
  geom_line(data=a5, aes(x=projectedyear, y=estimate,
                         group=as.factor(Mt), colour=as.factor(Mt)), size=1)+
  scale_colour_manual("", values=pal_j,
                      labels=labels)+
  geom_hline(yintercept=start, colour="darkgreen")+
  geom_hline(yintercept=end, colour="darkgreen", linetype="dotted")+
  geom_hline(yintercept=1, colour="black", linetype="dashed")+
  xlim(0, 1000)+
  xlab("year")+
  ylab("species evenness")+
  theme_classic() +
  ggtitle("J.")

g <- plot_grid(ga, gb, gc, gd, ge, gf, gg, gh, gi, gj, nrow = 2, byrow = FALSE)
save_plot("outputs/fig_2.pdf", g, nrow = 2, base_width = 100, base_height = 20, units="cm")


