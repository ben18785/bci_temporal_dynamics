.PHONY: all

all: data/processed/reproductives_stan_data.rds\
	data/processed/stan_fits/overall_freq_dependent.rds\
	data/processed/stan_fits/overall_freq_independent.rds\
	data/processed/stan_fits/overall_neutral.rds

data/processed/reproductives_stan_data.rds: src/R/prepare_stan_data.R data/processed/BCI_summary_data_forben_reproductivesonly_2Oct.csv
	Rscript $<

data/processed/stan_fits/overall_freq_dependent.rds: src/R/fit_overall.R data/processed/reproductives_stan_data.rds
	Rscript $< overall_freq_dependent

data/processed/stan_fits/overall_freq_independent.rds: src/R/fit_overall.R data/processed/reproductives_stan_data.rds
	Rscript $< overall_freq_independent

data/processed/stan_fits/overall_neutral.rds: src/R/fit_overall.R data/processed/reproductives_stan_data.rds
	Rscript $< overall_neutral
