check_diagnostics <- function(filename) {
  fit <- readRDS(filename)
  fit_diagnostics <- summarise_draws(fit)
  rhat_above_1.01 <- sum(fit_diagnostics$rhat > 1.01, na.rm = T)
  ess_bulk_below_400 <- sum(fit_diagnostics$ess_bulk < 400, na.rm = T)
  ess_tail_below_400 <- sum(fit_diagnostics$ess_tail < 400, na.rm = T)
  list(rhat=rhat_above_1.01,
       ess_bulk=ess_bulk_below_400,
       ess_tail=ess_tail_below_400)
}

truncated_normal <- function(mu, sigma) {
  val <- rnorm(1, mu, sigma)
  if(val < 0)
    val <- truncated_normal(mu, sigma)
  val
}

rmvrnorm2D <- function(n, mux, muy, sigmax, sigmay, rho){
  return(rmvnorm(n, c(mux, muy),
                 matrix(c(sigmax^2, sigmax * sigmay * rho,
                          sigmax * sigmay * rho, sigmay^2),
                        ncol = 2)))
}

inv_logit <- function(x) {
  1 / (1 + exp(-x))
}
