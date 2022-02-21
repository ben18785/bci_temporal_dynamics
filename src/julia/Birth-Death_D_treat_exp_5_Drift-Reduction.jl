## Script family description
    # These scripts build the functions to model the BCI population using time series data.
    # This is done using a Birth-Death model including selection for births and deaths and migration.
    # The scripts are named sequentially A, B...E and every script includes the previous script.
    # The final script "Birth-Death_E_master-script" runs all simulation experiments.
    #
## This Script`s description
    # This script creates the treatments and sets the input values for experiment 5.
    # Exp. 5 reduces drift by increasing the population size.
    # Inputs are year and replications.
    # The outputs are the starting values year and replicates and a treatment matrix T.
    #
## Author: Jerónimo Cid, follwoing my Master thesis at Imperial College London.
    # Contact details:        |                       |
    # Author;                 Supervisor;             Co-supervisor;
    # Jerónimo Cid;           Armand M. Leroi;        Ben Lambert
    # jernimo.cid19@ic.ac.uk; a.leroi@imperial.ac.uk; ben.c.lambert@gmail.com
    # date: 30/07/2021
    #
## Call the previous script (Birth-Death_C_treatments.jl)
    include("Birth-Death_C_treatments.jl") # call the experimental parameters
    #
## Parameters of the experiment
       treatment_drift_red = DataFrame(treat_code_Svt_BBt_Dt_Mt = ["1_1_1_1","1_1_5_1","1_1_10_1",  # Sv, BB, Dt
                   "1_1_50_1", "1_1_100_1","1_1_500_1","1_1_1000_1","1_1_5000_1","1_1_10000_1"],
                       SVt = [1,1,1,1,1,1,1,1,1],
                       BBt = [1,1,1,1,1,1,1,1,1],
                       Dt  = [1,5,10,50,100,500,1000,5000,10000],
                       Mt  = [1,1,1,1,1,1,1,1,1])
       T = treatment_drift_red
       replicates = 100
       exp_name = "exp_5-"
       year = 2015
       filepath = "data/processed/julia_runs/Exp-5_Drift-Reduction"

## Run Treatments
@time Treatment_reps = Treatment_loop_f(T) #
