.PHONY: all stan_fitting stan_fitting_birth_death julia_outputs r_post_julia

HOLDOUTS := $(shell seq 1 7)
HOLDOUT_NEUTRAL_FITS := $(addsuffix .rds, $(addprefix data/processed/stan_fits/overall_neutral_hold_out_, $(HOLDOUTS)))
HOLDOUT_DEP_FITS := $(addsuffix .rds, $(addprefix data/processed/stan_fits/overall_freq_dependent_hold_out_, $(HOLDOUTS)))
HOLDOUT_INDEP_FITS := $(addsuffix .rds, $(addprefix data/processed/stan_fits/overall_freq_independent_hold_out_, $(HOLDOUTS)))
HOLDOUT_RW_FITS := $(addsuffix .rds, $(addprefix data/processed/stan_fits/overall_freq_rw_hold_out_, $(HOLDOUTS)))
HOLDOUT_SPLIT_FITS := $(addsuffix .rds, $(addprefix data/processed/stan_fits/overall_freq_independent_split_hold_out_, $(HOLDOUTS)))
QUARTERS := $(shell seq 1 4)
QUARTER_FITS := $(addsuffix .rds, $(addprefix data/processed/stan_fits/quartered_, $(QUARTERS)))
# $(info VAR="$(HOLDOUT_DEP_FITS)")

stan_fitting: data/processed/model_comparison.rds\
	data/processed/model_comparison_hold_out.rds\
	data/processed/stan_fits/overall_freq_rw.rds\
	data/processed/freq_independent_parameters.rds\
	outputs/time_varying_rw.pdf

stan_fitting_birth_death: data/processed/reproductives_stan_birth_death_data.rds\
	data/processed/birth_death_estimates.rds\
	data/processed/stan_fits/birth_death.rds\
	outputs/posterior_pred_birth_death_recruitment.pdf\
	data/processed/prior_predictive_birth_death.rds\
	outputs/prior_predictive_birth_death.pdf\
	data/processed/population_birth_death_samples.rds\
	data/processed/quartered_betas.rds\
	data/processed/birth_death_betas.csv\
	data/processed/N_trees.csv

julia_outputs: data/processed/julia_runs/Exp-1_Wildtype-Extension/exp_1-1_1_1_1_1.csv\
	data/processed/julia_runs/Exp-3_Sel_on-off_equal/exp_3-1_1_1_1_1.csv\
	data/processed/julia_runs/Exp-4_Drift-Increase/exp_4-1_1_1_1_1.csv\
	data/processed/julia_runs/Exp-5_Drift-Reduction/exp_5-1_1_1_1_1.csv\
	data/processed/julia_runs/Exp-2_Migration-Revamping/exp_2-1_1_1_1_1.csv

r_post_julia: data/processed/exp_1_diversity.csv\
	data/processed/exp_1_most_abundant.csv\
	data/processed/exp_1_counts.csv\
	data/processed/exp_2_diversity.csv\
	data/processed/exp_3_diversity.csv\
	data/processed/exp_4_diversity.csv\
	data/processed/exp_5_diversity.csv

figure_making: outputs/fig_1.pdf\
	outputs/fig_2.pdf

all: stan_fitting\
	stan_fitting_birth_death\
	julia_outputs\
	r_post_julia

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

data/processed/stan_fits/overall_freq_dependent.rds: src/R/fit_overall.R\
	data/processed/reproductives_stan_data.rds
	Rscript $< overall_freq_dependent 4000 4 2 -99

data/processed/stan_fits/overall_freq_independent.rds: src/R/fit_overall.R\
	data/processed/reproductives_stan_data.rds
	Rscript $< overall_freq_independent 8000 4 10 -99

data/processed/stan_fits/overall_freq_independent_split.rds: src/R/fit_overall.R\
	data/processed/reproductives_stan_data.rds
	Rscript $< overall_freq_independent_split 8000 4 10 -99

data/processed/stan_fits/overall_freq_rw.rds: src/R/fit_overall.R\
	data/processed/reproductives_stan_data.rds
	Rscript $< overall_freq_rw 8000 4 10 -99

data/processed/stan_fits/overall_neutral.rds: src/R/fit_overall.R\
	data/processed/reproductives_stan_data.rds
	Rscript $< overall_neutral 4000 4 2 -99

data/processed/stan_fits/diagnostics.rds: src/R/stanfit_diagnostic_checks.R\
	data/processed/stan_fits/overall_freq_dependent.rds\
	data/processed/stan_fits/overall_freq_independent.rds\
	data/processed/stan_fits/overall_freq_rw.rds\
	data/processed/stan_fits/overall_neutral.rds\
	data/processed/stan_fits/overall_freq_independent_split.rds
	Rscript $<

data/processed/model_comparison.rds: src/R/model_comparison.R\
	data/processed/stan_fits/diagnostics.rds\
	data/processed/stan_fits/overall_freq_dependent.rds\
	data/processed/stan_fits/overall_freq_independent.rds\
	data/processed/stan_fits/overall_neutral.rds
	Rscript $<

outputs/time_varying_rw.pdf: src/R/plot_rw_parameters.R\
	data/processed/reproductives_stan_data.rds\
	data/processed/stan_fits/overall_freq_rw.rds
	Rscript $<

$(HOLDOUT_DEP_FITS): data/processed/stan_fits/overall_freq_dependent_hold_out_%.rds: src/R/fit_overall.R\
	data/processed/reproductives_stan_data.rds\
	src/stan/overall_freq_dependent.stan
	Rscript $< overall_freq_dependent 4000 4 2 $*

$(HOLDOUT_INDEP_FITS): data/processed/stan_fits/overall_freq_independent_hold_out_%.rds: src/R/fit_overall.R\
	data/processed/reproductives_stan_data.rds\
	src/stan/overall_freq_independent.stan
	Rscript $< overall_freq_independent 8000 4 10 $*

$(HOLDOUT_SPLIT_FITS): data/processed/stan_fits/overall_freq_independent_split_hold_out_%.rds: src/R/fit_overall.R\
	data/processed/reproductives_stan_data.rds\
	src/stan/overall_freq_independent_split.stan
	Rscript $< overall_freq_independent_split 8000 4 10 $*

$(HOLDOUT_RW_FITS): data/processed/stan_fits/overall_freq_rw_hold_out_%.rds: src/R/fit_overall.R\
	data/processed/reproductives_stan_data.rds\
	src/stan/overall_freq_rw.stan
	Rscript $< overall_freq_rw 16000 4 20 $*

$(HOLDOUT_NEUTRAL_FITS): data/processed/stan_fits/overall_neutral_hold_out_%.rds: src/R/fit_overall.R\
	data/processed/reproductives_stan_data.rds
	Rscript $< overall_neutral 4000 4 2 $*

data/processed/stan_fits/diagnostics_holdout.rds: src/R/stanfit_diagnostic_hold_out_checks.R\
	$(HOLDOUT_DEP_FITS)\
	$(HOLDOUT_INDEP_FITS)\
	$(HOLDOUT_RW_FITS)\
	$(HOLDOUT_NEUTRAL_FITS)\
	$(HOLDOUT_SPLIT_FITS)
	Rscript $<

data/processed/model_comparison_hold_out.rds:src/R/model_comparison_hold_out.R\
	data/processed/stan_fits/diagnostics_holdout.rds
	Rscript $<

data/processed/freq_independent_parameters.rds: src/R/freq_independent_parameters.R\
	data/processed/reproductives_stan_data.rds\
	data/processed/stan_fits/overall_freq_independent.rds
	Rscript $<

data/processed/reproductives_stan_birth_death_data.rds: src/R/prepare_stan_data_birth_death.R\
	data/processed/bci_cleaned.rds
	Rscript $<

data/processed/birth_death_image.RData: data/processed/reproductives_stan_birth_death_data.rds

data/processed/prior_predictive_birth_death.rds: src/R/prior_predictive_birth_death.R
	Rscript $<

outputs/prior_predictive_birth_death.pdf: src/R/prior_predictive_plot.R\
	data/processed/prior_predictive_birth_death.rds
	Rscript $<

data/processed/stan_fits/birth_death.rds: src/R/fit_birth_and_death.R\
	data/processed/reproductives_stan_birth_death_data.rds\
	src/stan/birth_and_death.stan
	Rscript $< 160000 4 80

data/processed/stan_fits/diagnostics_birth_death.rds: src/R/stanfit_birth_death_diagnostic_checks.R\
	data/processed/stan_fits/birth_death.rds
	Rscript $<

outputs/posterior_pred_birth_death_recruitment.pdf: src/R/posterior_predictive_check_birth_death.R\
	data/processed/stan_fits/birth_death.rds\
	data/processed/birth_death_image.RData\
	data/processed/stan_fits/diagnostics_birth_death.rds
	Rscript $<

outputs/posterior_pred_birth_death_mort_size.pdf: outputs/posterior_pred_birth_death_recruitment.pdf
outputs/posterior_pred_birth_death_mort_time.pdf: outputs/posterior_pred_birth_death_recruitment.pdf

data/processed/population_birth_death_samples.rds: src/R/posterior_population_generator.R\
	data/processed/stan_fits/birth_death.rds
	Rscript $<

data/processed/population_birth_death_samples.csv: data/processed/population_birth_death_samples.rds

data/processed/birth_death_estimates.rds: src/R/birth_death_parameters.R\
	data/processed/stan_fits/birth_death.rds\
	data/processed/birth_death_image.RData
	Rscript $<

data/processed/bci_reproductives_quartered.rds: src/R/prepare_quadrant_data.R\
	data/processed/bci_reproductives.rds
	Rscript $<

data/processed/bci_cleaned_quartered.rds: src/R/remove_lazarus_quartered.R\
	data/processed/bci_reproductives_quartered.rds
	Rscript $<

$(QUARTER_FITS): data/processed/stan_fits/quartered_%.rds: src/R/fit_quartered.R\
	data/processed/bci_cleaned_quartered.rds
	Rscript $< $* 8000 4 10

data/processed/quartered_betas.rds: src/R/compare_quartered_estimates.R\
	data/processed/bci_cleaned_quartered.rds\
	data/processed/stan_fits/quartered_1.rds\
	data/processed/stan_fits/quartered_2.rds\
	data/processed/stan_fits/quartered_3.rds\
	data/processed/stan_fits/quartered_4.rds
	Rscript $<

data/processed/birth_death_betas.csv: src/R/prepare_files_for_simulations.R\
	data/processed/birth_death_estimates.rds\
	data/processed/stan_fits/birth_death.rds
	Rscript $<

data/processed/birth_death_survive_annual.csv: data/processed/birth_death_betas.csv
data/processed/birth_death_medians.csv: data/processed/birth_death_survive_annual.csv
data/processed/birth_death_delta.csv: data/processed/birth_death_medians.csv
data/processed/initial_frequencies.csv: data/processed/birth_death_delta.csv

data/processed/N_trees.csv: src/R/generate_fraction_children.R\
	data/processed/bci_cleaned.rds
	Rscript $<
data/processed/data/processed/fraction_children_born_censusyear.csv: data/processed/N_trees.csv

# note that, for julia runs, I don't include all dependencies or outputs here since there are so many
data/processed/julia_runs/Exp-1_Wildtype-Extension/exp_1-1_1_1_1_1.csv: src/julia/Birth-Death_D_treat_exp_1_Wildtype_Ext.jl
	julia $<
data/processed/julia_runs/Exp-2_Migration-Revamping/exp_2-1_1_1_1_1.csv: src/julia/Birth-Death_D_treat_exp_2_Mig_Revamp.jl
	julia $<
data/processed/julia_runs/Exp-3_Sel_on-off_equal/exp_3-1_1_1_1_1.csv: src/julia/Birth-Death_D_treat_exp_3_Sel_on-off_equal.jl
	julia $<
data/processed/julia_runs/Exp-4_Drift-Increase/exp_4-1_1_1_1_1.csv: src/julia/Birth-Death_D_treat_exp_4_Drift-Increase.jl
	julia $<
data/processed/julia_runs/Exp-5_Drift-Reduction/exp_5-1_1_1_1_1.csv: src/julia/Birth-Death_D_treat_exp_5_Drift-Reduction.jl
	julia $<

# post_julia data processing
data/processed/exp_1_diversity.csv: src/R/exp_1_diversity.R\
	data/processed/julia_runs/Exp-1_Wildtype-Extension/exp_1-1_1_1_1_1.csv
	Rscript $<

data/processed/exp_1_most_abundant.csv: src/R/exp_1_most_abundant.R\
	data/processed/julia_runs/Exp-1_Wildtype-Extension/exp_1-1_1_1_1_1.csv
	Rscript $<

data/processed/exp_1_counts.csv: src/R/exp_1_counts.R\
	data/processed/julia_runs/Exp-1_Wildtype-Extension/exp_1-1_1_1_1_1.csv
	Rscript $<

data/processed/exp_2_diversity.csv: src/R/exp_2_diversity.R
	Rscript $<

# leaving out all dependencies here since there are many
data/processed/exp_3_diversity.csv: src/R/exp_3_diversity.R
	Rscript $<

# also leaving out all dependencies for same reason
data/processed/exp_4_diversity.csv: src/R/exp_4_diversity.R
	Rscript $<

data/processed/exp_5_diversity.csv: src/R/exp_5_diversity.R
	Rscript $<

# main plots for paper
data/processed/fig_1a_data.rds: src/R/fig_1_ab_frequency_independent.R\
	data/processed/freq_independent_parameters.rds\
	data/processed/bci_cleaned.rds
	Rscript $<
data/processed/fig_1b_data.rds: data/processed/fig_1a_data.rds

data/processed/fig_1c_data.rds: src/R/fig_1c_fitness_components.R\
	data/processed/birth_death_estimates.rds\
	data/processed/stan_fits/overall_freq_independent.rds\
	data/processed/reproductives_stan_birth_death_data.rds
	Rscript $<

outputs/fig_1.pdf: src/R/fig_1_all_panels.R\
	data/processed/fig_1a_data.rds\
	data/processed/fig_1b_data.rds\
	data/processed/fig_1c_data.rds
	Rscript $<

data/processed/fig_2a_data.rds: src/R/fig_2a.R\
	data/processed/bci_cleaned.rds\
	data/processed/exp_1_diversity.csv
	Rscript $<
data/processed/fig_2b_data.rds: src/R/fig_2b.R\
	data/processed/bci_cleaned.rds
	Rscript $<
data/processed/fig_2c_data.rds: src/R/fig_2c.R\
	data/processed/exp_3_diversity.csv\
	data/processed/bci_cleaned.rds
	Rscript $<
data/processed/fig_2d_data.rds: src/R/fig_2d.R\
	data/processed/exp_3_diversity.csv\
	data/processed/bci_cleaned.rds
	Rscript $<
data/processed/fig_2e_data.rds: src/R/fig_2e.R\
	data/processed/exp_5_diversity.csv
	data/processed/bci_cleaned.rds
	Rscript $<
data/processed/fig_2f_data.rds: src/R/fig_2e.R\
	data/processed/exp_5_diversity.csv
	data/processed/bci_cleaned.rds
	Rscript $<
data/processed/fig_2g_data.rds: src/R/fig_2g.R\
	data/processed/bci_cleaned.rds\
	data/processed/exp_2_diversity.csv
	Rscript $<
data/processed/fig_2h_data.rds: src/R/fig_2h.R\
	data/processed/bci_cleaned.rds\
	data/processed/exp_2_diversity.csv
	Rscript $<
data/processed/fig_2i_data.rds: src/R/fig_2i.R\
	data/processed/bci_cleaned.rds\
	data/processed/exp_2_diversity.csv
	Rscript $<
data/processed/fig_2j_data.rds: src/R/fig_2j.R\
	data/processed/bci_cleaned.rds\
	data/processed/exp_2_diversity.csv
	Rscript $<

outputs/fig_2.pdf: src/R/fig_2_all_panels.R\
	data/processed/fig_2a_data.rds\
	data/processed/fig_2b_data.rds\
	data/processed/fig_2c_data.rds\
	data/processed/fig_2d_data.rds\
	data/processed/fig_2e_data.rds\
	data/processed/fig_2f_data.rds\
	data/processed/fig_2g_data.rds\
	data/processed/fig_2h_data.rds\
	data/processed/fig_2i_data.rds\
	data/processed/fig_2j_data.rds
	Rscript $<



