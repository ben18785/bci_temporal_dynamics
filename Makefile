.PHONY: all

HOLDOUTS := $(shell seq 1 7)
HOLDOUT_NEUTRAL_FITS := $(addsuffix .rds, $(addprefix data/processed/stan_fits/overall_neutral_hold_out_, $(HOLDOUTS)))
HOLDOUT_DEP_FITS := $(addsuffix .rds, $(addprefix data/processed/stan_fits/overall_freq_dependent_hold_out_, $(HOLDOUTS)))
HOLDOUT_INDEP_FITS := $(addsuffix .rds, $(addprefix data/processed/stan_fits/overall_freq_independent_hold_out_, $(HOLDOUTS)))
# $(info VAR="$(HOLDOUT_DEP_FITS)")

all: data/processed/model_comparison.rds\
	data/processed/model_comparison_hold_out.rds\
	data/processed/reproductives_stan_birth_death_data.rds

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

data/processed/reproductives_stan_data.rds: src/R/prepare_stan_data.R
	Rscript $<

data/processed/stan_fits/overall_freq_dependent.rds: src/R/fit_overall.R data/processed/reproductives_stan_data.rds
	Rscript $< overall_freq_dependent 4000 4 2 -99

data/processed/stan_fits/overall_freq_independent.rds: src/R/fit_overall.R data/processed/reproductives_stan_data.rds
	Rscript $< overall_freq_independent 8000 4 10 -99

data/processed/stan_fits/overall_neutral.rds: src/R/fit_overall.R data/processed/reproductives_stan_data.rds
	Rscript $< overall_neutral 4000 4 2 -99

data/processed/stan_fits/diagnostics.rds: src/R/stanfit_diagnostic_checks.R\
	data/processed/stan_fits/overall_freq_dependent.rds\
	data/processed/stan_fits/overall_freq_independent.rds\
	data/processed/stan_fits/overall_neutral.rds
	Rscript $<

data/processed/model_comparison.rds: src/R/model_comparison.R\
	data/processed/stan_fits/diagnostics.rds\
	data/processed/stan_fits/overall_freq_dependent.rds\
	data/processed/stan_fits/overall_freq_independent.rds\
	data/processed/stan_fits/overall_neutral.rds
	Rscript $<

$(HOLDOUT_DEP_FITS): data/processed/stan_fits/overall_freq_dependent_hold_out_%.rds: src/R/fit_overall.R data/processed/reproductives_stan_data.rds
	Rscript $< overall_freq_dependent 4000 4 2 $*

$(HOLDOUT_INDEP_FITS): data/processed/stan_fits/overall_freq_independent_hold_out_%.rds: src/R/fit_overall.R data/processed/reproductives_stan_data.rds
	Rscript $< overall_freq_independent 8000 4 10 $*

$(HOLDOUT_NEUTRAL_FITS): data/processed/stan_fits/overall_neutral_hold_out_%.rds: src/R/fit_overall.R data/processed/reproductives_stan_data.rds
	Rscript $< overall_neutral 4000 4 2 $*

data/processed/stan_fits/diagnostics_holdout.rds: src/R/stanfit_diagnostic_hold_out_checks.R\
	$(HOLDOUT_DEP_FITS)\
	$(HOLDOUT_INDEP_FITS)\
	$(HOLDOUT_NEUTRAL_FITS)
	Rscript $<

data/processed/model_comparison_hold_out.rds:src/R/model_comparison_hold_out.R\
	data/processed/stan_fits/diagnostics_holdout.rds
	Rscript $<

data/processed/reproductives_stan_birth_death_data.rds: src/R/prepare_stan_data_birth_death.R\
	data/processed/bci_cleaned.rds
	Rscript $<
