.PHONY: all

all: data/processed/reproductives_stan_data.rds

data/processed/reproductives_stan_data.rds: src/R/prepare_stan_data.R data/processed/BCI_summary_data_forben_reproductivesonly_2Oct.csv
	Rscript $<
