library(rstan)
library(tidyverse)
library(reshape2)

diagnostic_check <- readRDS("data/processed/stan_fits/diagnostics_birth_death.rds")
# a few tail esses marginally below 400
stopifnot(diagnostic_check$rhat == 0)

fit <- readRDS("data/processed/stan_fits/birth_death.rds")

load("data/processed/birth_death_image.RData")

# deaths --------
lower <- apply(rstan::extract(fit, "p_survive_annual")[[1]], 2, function(x) quantile(x, 0.25))
upper <- apply(rstan::extract(fit, "p_survive_annual")[[1]], 2, function(x) quantile(x, 0.75))
p_survive_annual <- apply(rstan::extract(fit, "p_survive_annual")[[1]], 2, median)

comparison_df <- tibble(species_id=seq_along(p_survive_annual),
                        p_survive_annual=p_survive_annual,
                        lower=lower,
                        upper=upper) %>%
  right_join(df_short) %>%
  mutate(p_survive_sim=p_survive_annual^year_gap,
         lower=lower^year_gap,
         upper=upper^year_gap)

g <- comparison_df %>%
  ggplot(aes(x=p_survive, y=p_survive_sim)) +
  geom_pointrange(aes(ymin=lower, ymax=upper)) +
  geom_abline() +
  facet_wrap(~censusyear) +
  ylab("Estimated Pr(survival)") +
  xlab("Actual Pr(survival)")
ggsave("outputs/posterior_pred_birth_death_mort_time.pdf", g, width = 12, height = 8)

g2 <- comparison_df %>%
  mutate(size_cut=cut(N_parents, c(0, 5, 10, 50, 100, 1000, 100000), include.lowest = T)) %>%
  ggplot(aes(x=p_survive, y=p_survive_sim)) +
  geom_pointrange(aes(ymin=lower, ymax=upper)) +
  geom_abline() +
  facet_wrap(~size_cut) +
  ylab("Estimated Pr(survival)") +
  xlab("Actual Pr(survival)")
ggsave("outputs/posterior_pred_birth_death_mort_size.pdf", g2, width = 12, height = 8)

# births -------
counts_temp <- rstan::extract(fit, "counts_offspring_sim")[[1]]

counts_offspring_sim <- apply(counts_temp, c(2, 3), median) %>%
  t() %>%
  as.data.frame() %>%
  mutate(generation=seq_along(V1)) %>%
  mutate(type="simulated")

counts_offspring_low <- apply(counts_temp, c(2, 3),
                              function(x) quantile(x, 0.25)) %>%
  t() %>%
  as.data.frame() %>%
  mutate(generation=seq_along(V1)) %>%
  mutate(type="lower")

counts_offspring_high <- apply(counts_temp, c(2, 3),
                              function(x) quantile(x, 0.75)) %>%
  t() %>%
  as.data.frame() %>%
  mutate(generation=seq_along(V1)) %>%
  mutate(type="upper")

counts_actual <- counts_offspring %>%
  t() %>%
  as.data.frame() %>%
  mutate(generation=seq_along(`1`)) %>%
  mutate(type="actual")
colnames(counts_actual) <- colnames(counts_offspring_sim)

counts_all <- counts_actual %>%
  bind_rows(counts_offspring_sim) %>%
  bind_rows(counts_offspring_high) %>%
  bind_rows(counts_offspring_low)

temp <- counts_all %>%
  melt(id.vars=c("generation", "type")) %>%
  pivot_wider(id_cols = c("generation", "variable"),
              names_from="type", values_from="value")

g <- temp %>%
  ggplot(aes(x=actual, y=simulated)) +
  geom_pointrange(aes(ymin=lower, ymax=upper)) +
  geom_abline() +
  scale_x_sqrt() +
  scale_y_sqrt() +
  xlab("Actual offspring count") +
  ylab("Simulated offspring count") +
  geom_smooth(se=F)

ggsave("outputs/posterior_pred_birth_death_recruitment.pdf", g, width = 12, height = 8)
