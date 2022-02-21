readme.txt for BCI input files for simulations

These are:

initial_frequencies.csv: contains the initial counts for every species.

birth_death_betas.csv and birth_death_survive_annual.csv contain the sample runs
of the betas and annual survivals parameters for the birth_death model. 
The first column is the species name; subsequent columns are samples

birth_death_medians.csv: contains the median parameters for each species for 
both the betas and the annual survival

birth_death_delta.csv: this is the single delta value needed for the simulations.

population_birth_death_samples.csv: This are 10.000 combinations of "plausible" 
species used for generating new migrants

export-N_trees-fraction_children.rmd: SCRIPT (not file) to produce the N_trees.csv and 
fraction_children_born_censusyear.csv files.

BCI_summary_data_forben_reproductivesonly_2Oct.csv: contains reproductive counts to calculate N_trees.

N_trees.csv: contains the total number of trees for all species in each census year. 

fraction_children_born_censusyear.csv: contains the average offspring per reproductive for each census year.

