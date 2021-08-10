library(tidyverse)
library(rstan)

stan_data <- readRDS("data/processed/reproductives_stan_data.rds")
names <- stan_data$names

fit <- readRDS("data/processed/stan_fits/overall_freq_rw.rds")

beta <- rstan::extract(fit, "beta")[[1]]
beta <- colMeans(beta)

colnames(beta) <- names
generations <- c(1982, 1990, 1995, 2000, 2005, 2010, 2015)

beta <- beta %>%
  as.data.frame() %>%
  mutate(generation=generations) %>%
  pivot_longer(-generation)

beta_summary <- beta %>%
  group_by(name) %>%
  summarise(dev=sd(value)) %>%
  arrange(desc(dev))

n_movers <- 60
top_movers <- beta_summary$name[1:n_movers]

g <- beta %>%
  filter(name %in% top_movers) %>%
  ggplot(aes(generation, value)) +
  geom_line(aes(group=name)) +
  geom_smooth(se=F) +
  ylab("Estimate of beta") +
  xlab("Census year")
ggsave("outputs/time_varying_rw.pdf", g, width = 8, height = 6)

# sd in beta vs frequency
# counts <- stan_data$counts %>%
#   as.data.frame() %>%
#   mutate(species=names) %>%
#   pivot_longer(-"species") %>%
#   group_by(species) %>%
#   summarise(count=mean(value)) %>%
#   rename(name=species) %>%
#   left_join(beta_summary)
#
# counts %>%
#   ggplot(aes(count, dev)) +
#   geom_point() +
#   scale_x_sqrt() +
#   geom_smooth() +
#   xlab("Count") +
#   ylab("Deviation in beta")
