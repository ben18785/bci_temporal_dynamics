library(rstan)
library(posterior)
source("src/R/helper.R")

hold_out_diagnostics <- function(modelname, holdout) {
  filename <- paste0("data/processed/stan_fits/",
                     modelname, "_hold_out_", holdout, ".rds")
  check_diagnostics(filename)
}

m_diagnostics <- matrix(nrow = 7 * 3 * 3,
                        ncol = 4)
models <- c("overall_neutral", "overall_freq_dependent",
            "overall_freq_independent")
params <- c("Rhat", "ESS_bulk", "ESS_tail")
holdouts <- seq(1, 7, 1)
count <- 1
for(i in seq_along(holdouts)) {
  for(j in seq_along(models)) {
    model <- models[j]
    holdout <- holdouts[i]
    print(paste(model, ": ", holdout))
    diag_temp <- hold_out_diagnostics(model, holdout)
    for(k in seq_along(params)) {
      m_diagnostics[count, ] <- c(model, holdout,
                                  params[k], diag_temp[[k]])
      count <- count + 1
    }
  }
}
colnames(m_diagnostics) <- c("model", "holdout", "parameter", "value")
m_diagnostics <- as.data.frame(m_diagnostics)

saveRDS(m_diagnostics, "data/processed/stan_fits/diagnostics_holdout.rds")
