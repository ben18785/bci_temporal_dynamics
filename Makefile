.PHONY: all

all: data/processed/bci_cleaned.rds\
  data/processed/reproductives_stan_data.rds\
	data/processed/stan_fits/overall_freq_dependent.rds\
	data/processed/stan_fits/overall_freq_independent.rds\
	data/processed/stan_fits/overall_neutral.rds

data/processed/bci_reproductives.rds: src/R/clean_and_produce_reproductives_data.R\
	data/raw/bci.tree1.rdata\
	data/raw/bci.tree2.rdata\
	data/raw/bci.tree3.rdata\
	data/raw/bci.tree4.rdata\
	data/raw/bci.tree5.rdata\
	data/raw/bci.tree6.rdata\
	data/raw/bci.tree7.rdata\
	data/raw/bci.tree8.rdata\
	data/raw/BCI_all_functional_data.csv
	Rscript $<

data/processed/bci_cleaned.rds: src/R/remove_lazarus.R\
	data/processed/bci_reproductives.rds
	Rscript $<

data/processed/reproductives_stan_data.rds: src/R/prepare_stan_data.R data/processed/BCI_summary_data_forben_reproductivesonly_2Oct.csv
	Rscript $<

data/processed/stan_fits/overall_freq_dependent.rds: src/R/fit_overall.R data/processed/reproductives_stan_data.rds
	Rscript $< overall_freq_dependent

data/processed/stan_fits/overall_freq_independent.rds: src/R/fit_overall.R data/processed/reproductives_stan_data.rds
	Rscript $< overall_freq_independent

data/processed/stan_fits/overall_neutral.rds: src/R/fit_overall.R data/processed/reproductives_stan_data.rds
	Rscript $< overall_neutral
