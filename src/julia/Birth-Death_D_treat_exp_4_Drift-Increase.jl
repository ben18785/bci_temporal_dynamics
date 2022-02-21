## Script family description
    # These scripts build the functions to model the BCI population using time series data.
    # This is done using a Birth-Death model including selection for births and deaths and migration.
    # The scripts are named sequentially A, B...E and every script includes the previous script.
    # The final script "Birth-Death_E_master-script" runs all simulation experiments.
    #
## This Script`s description
    # This script creates the treatments and sets the input values for experiment 4.
    # Exp. 4 increases drift while leaving the rest constant. Takes 13 hours for the observed series length 2015..
    # There are no inputs to this script.
    # The outputs are the starting values year and replicates and a treatment matrix T.
    #
## Author: Jerónimo Cid, follwoing my Master thesis at Imperial College London.
    # Contact details:        |                       |
    # Author;                 Supervisor;             Co-supervisor;
    # Jerónimo Cid;           Armand M. Leroi;        Ben Lambert
    # jernimo.cid19@ic.ac.uk; a.leroi@imperial.ac.uk; ben.c.lambert@gmail.com
    # date: 30/07/2021
## Call the previous script (Birth-Death_C_treatments.jl)
    include("Birth-Death_C_treatments.jl") # call the experimental parameters
    #
## Parameters of the experiment
       treatment_drift_inc = DataFrame(treat_code_Svt_BBt_Dt_Mt = ["1_1_1_1","1_1_0.9_1","1_1_0.8_1","1_1_0.7_1","1_1_0.6_1","1_1_0.5_0","1_1_0.4_1","1_1_0.3_1","1_1_0.2_1","1_1_0.1_1"], # Sv, BB, Dt
                       SVt = [1,1,1,1,1,1,1,1,1,1],
                       BBt = [1,1,1,1,1,1,1,1,1,1],
                       Dt  = [1,0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1],
                       Mt  = [1,1,1,1,1,1,1,1,1,1])

       T = treatment_drift_inc
       replicates = 100
       exp_name = "exp_4-"
       year = 2015
       filepath = "data/processed/julia_runs/Exp-4_Drift-Increase"

## Run Treatments
@time Treatment_reps = Treatment_loop_f(T) #
