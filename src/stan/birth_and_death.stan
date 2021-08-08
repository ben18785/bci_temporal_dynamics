data{
  // births
  int N_generations; // number of generations
  int N_species; // num variants
  int firstAppearance[N_species]; // generation when each variant first appears
  int mutantCounts[N_generations]; // counts of mutant variants in each generation
  int counts_parents[N_species, N_generations]; // counts of variants in each generation
  int counts_offspring[N_species, N_generations]; // counts of variants in each generation
  int activeVariantCount[N_generations]; // counts of non-zero parents in each generation

  // deaths
  int N_death_obs;
  int N_survive[N_death_obs];
  int N_parents[N_death_obs];
  int species_death[N_death_obs];
  vector[N_death_obs] year_gap;
}

parameters{
  // birth model
  real<lower=-1, upper=1> beta[N_species];
  real<lower=0, upper=1> delta;

  // death model
  vector[N_species] logit_p_survive_annual;

  // hierarchical parameters
  vector[2] mu;
  real<lower=-1, upper=1> rho;
  vector<lower=0>[2] sigma;
}

transformed parameters {
  vector[N_species] p_survive_annual = inv_logit(logit_p_survive_annual);
  cov_matrix[2] Sigma;
  matrix[N_species, 2] theta;
  Sigma[1, 1] = sigma[1]^2;
  Sigma[1, 2] = rho * sigma[1] * sigma[2];
  Sigma[2, 1] = rho * sigma[1] * sigma[2];
  Sigma[2, 2] = sigma[2]^2;
  for(i in 1:N_species) {
    theta[i, 1] = beta[i];
    theta[i, 2] = logit_p_survive_annual[i];
  }
}

model{
  for(i in 1:N_generations){
    vector[activeVariantCount[i] + 1] f; // number of active variants + mutants
    int countsTemp[activeVariantCount[i] + 1];
    int count = 1;
    for(j in 1:N_species){
      if(counts_parents[j, i] > 0){
        f[count] = counts_parents[j, i];
        countsTemp[count] = counts_offspring[j, i];
        count += 1;
      }
    }
    f[activeVariantCount[i] + 1] = 0;
    countsTemp[activeVariantCount[i] + 1] = mutantCounts[i];
    f = f / sum(f);
    count = 1;
    for(j in 1:N_species){
      if(counts_parents[j, i] > 0){
        if(i == 1) {
          f[count] = f[count] * (1 + beta[j])^(3.0 / 5.0); // correct as beta[j]
        } else {
          f[count] = f[count] * (1 + beta[j]); // correct as beta[j]
        }
        count += 1;
      }
    }
    f[activeVariantCount[i] + 1] = 0;
    f = f / sum(f);
    f = f * (1 - delta);
    f[activeVariantCount[i] + 1] = delta;
    countsTemp ~ multinomial(f);
  }

  for(i in 1:N_death_obs)
    N_survive[i] ~ binomial(N_parents[i], p_survive_annual[species_death[i]]^year_gap[i]);

  // priors assume beta and p_survive_annual are sorted so that each element
  // corresponds to same species
  for(i in 1:N_species)
    theta[i] ~ multi_normal(mu, Sigma);

  mu[1] ~ normal(0, 0.5);
  mu[2] ~ normal(3, 0.5);
  sigma[1] ~ normal(0.5, 0.5);
  sigma[2] ~ normal(2, 1);
}

generated quantities {
  int counts_offspring_sim[N_species, N_generations];
  for(j in 1:N_species)
    for(i in 1:N_generations)
      counts_offspring_sim[j, i] = 0;

  {
    for(i in 1:N_generations){
      int indexes[activeVariantCount[i]];
      vector[activeVariantCount[i] + 1] f; // number of active variants + mutants
      int countsTemp[activeVariantCount[i] + 1];
      int count = 1;
      for(j in 1:N_species){
        if(counts_parents[j, i] > 0){
          f[count] = counts_parents[j, i];
          count += 1;
        }
      }
      f[activeVariantCount[i] + 1] = 0;
      countsTemp[activeVariantCount[i] + 1] = mutantCounts[i];
      f = f / sum(f);
      count = 1;
      for(j in 1:N_species){
        if(counts_parents[j, i] > 0){
          if(i == 1) {
          f[count] = f[count] * (1 + beta[j])^(3.0 / 5.0); // correct as beta[j]
        } else {
          f[count] = f[count] * (1 + beta[j]); // correct as beta[j]
        }
          indexes[count] = j;
          count += 1;
        }
      }
      f[activeVariantCount[i] + 1] = 0;
      f = f / sum(f);
      f = f * (1 - delta);
      f[activeVariantCount[i] + 1] = delta;
      countsTemp = multinomial_rng(f, sum(counts_offspring[:, i]));

      for(j in 1:activeVariantCount[i]) {
        counts_offspring_sim[indexes[j], i] = countsTemp[j];
      }
    }
  }
}
