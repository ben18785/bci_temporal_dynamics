## Script family description
    # These scripts build the functions to model the BCI population using time series data.
    # This is done using a Birth-Death model including selection for births and deaths and migration.
    # The scripts are named sequentially A, B...E and every script includes the previous script.
    # The final script "Birth-Death_E_master-script" runs all simulation experiments.
    #
## This Script`s description
    # This script creates the treatments and sets the input values for experiment 2.
    # Exp. 2 increases migration while leaving the rest constant. Inputs are year and replications.
    # The inputs are the same five of the replicates function (replicates, year, Dt, BBt, SVt, and Mt).
    # The outputs are the starting values year and replicates and a treatment matrix T.

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
       treatment_migration = DataFrame(treat_code_Svt_BBt_Dt_Mt = ["1_1_1_1","1_1_1_2","1_1_1_3","1_1_1_4","1_1_1_5","1_1_1_6","1_1_1_7","1_1_1_8"], # Sv, BB, Dt
                       SVt = [1,1,1,1,1,1,1,1],
                       BBt = [1,1,1,1,1,1,1,1],
                       Dt  = [1,1,1,1,1,1,1,1],
                       Mt  = [1,2,3,4,5,6,7,8])

       T = treatment_migration
       year = 3000
       replicates = 2
       exp_name = "exp_2-"
       filepath = "data/processed/julia_runs/Exp-2_Migration-Revamping"


## Run Treatments
@time Treatment_reps = Treatment_loop_f(T) # # 8 hours Mig. Revamping
