library(tidyverse)

df <- readRDS("data/processed/prior_predictive_birth_death.rds")

g <- df %>%
  ggplot(aes(x=beta, y=p)) +
  geom_point()
ggsave("outputs/prior_predictive_birth_death.pdf", g,
       width = 7, height = 5)

quantile(df$beta, c(0.025, 0.5, 0.975))
quantile(df$p, c(0.025, 0.5, 0.975))
