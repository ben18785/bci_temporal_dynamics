data{
  int N; // number of generations
  int K; // num variants
  int firstAppearance[K]; // generation when each variant first appears
  int mutantCounts[(N-1)]; // counts of mutant variants in each generation
  int counts[K,N]; // counts of variants in each generation
  int activeVariantCount[N]; // number of variants that have appeared thus far
  int hold_out;
}

parameters{
  matrix[N - 1, K - 1] logit_beta;
  real<lower=0,upper=1> delta;
  real<lower=0> sigma;
}

transformed parameters {
  matrix[N - 1, K] beta;
  for(k in 1:K) {
    if(k < K)
      beta[, k] = -1 + inv_logit(logit_beta[, k]) * 2;
    else
      beta[, k] = rep_vector(0, N-1);
  }
}

model{
  for(i in 1:(N - 1)){
    if(i != hold_out) {
    vector[activeVariantCount[i] + 1] f; // number of active variants + mutants
    int countsTemp[activeVariantCount[i] + 1];
    real delta_temp = delta;
    for(j in 1:activeVariantCount[i]){
      f[j] = counts[j, i];
      countsTemp[j] = counts[j,(i + 1)];
    }
    f[activeVariantCount[i] + 1] = 0;
    countsTemp[activeVariantCount[i] + 1] = mutantCounts[i];
    f = f / sum(f);
    for(j in 1:(activeVariantCount[i])){
      if(i > 1) {
        f[j] = f[j] * (1 + beta[i, j]);
      }
      else {
        f[j] = f[j] * (1 + beta[i, j])^(3.0 / 5.0);
        delta_temp = delta * (3.0 / 5.0); # note this should be * not ^
      }
    }
    f[activeVariantCount[i] + 1] = 0;
    f = f / sum(f);
    f = f * (1 - delta_temp);
    f[activeVariantCount[i] + 1] = delta_temp;
    countsTemp ~ multinomial(f);
  }
  }

  // rw priors
  for(j in 1:(K - 1)) {
    for(i in 1:(N - 1)) {
      if(i == 1) {
        logit_beta[i, j] ~ normal(0, 0.5);
      } else{
        logit_beta[i, j] ~ normal(logit_beta[i - 1, j], sigma);
      }
    }
  }
  sigma ~ normal(0, 0.1);
}

generated quantities{
  vector[N - 1] vLogLikelihood;

  for(i in 1:(N - 1)){
    real delta_temp = delta;
    vector[activeVariantCount[i] + 1] f;
    int countsTemp[activeVariantCount[i] + 1];
    for(j in 1:activeVariantCount[i]){
      f[j] = counts[j, i];
      countsTemp[j] = counts[j, (i + 1)];
    }
    f[activeVariantCount[i] + 1] = 0;
    countsTemp[activeVariantCount[i] + 1] = mutantCounts[i];
    f = f / sum(f);
    for(j in 1:(activeVariantCount[i] - 1)) {
      if(i > 1) {
        f[j] = f[j] * (1 + beta[i, j]);
      }
      else {
        f[j] = f[j] * (1 + beta[i, j])^(3.0 / 5.0);
        delta_temp = delta * (3.0 / 5.0); # note this should be * not ^
      }
    }
    f[activeVariantCount[i] + 1] = 0;
    f = f / sum(f);
    f = f * (1 - delta_temp);
    f[activeVariantCount[i] + 1] = delta_temp;
    vLogLikelihood[i] = multinomial_lpmf(countsTemp|f);
  }
}
