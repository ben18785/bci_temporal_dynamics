## Script family description
    # These scripts build the functions to model the BCI population using time series data.
    # This is done using a Birth-Death model including selection for births and deaths and migration.
    # The scripts are named sequentially A, B...E and every script includes the previous script.
    # The final script "Birth-Death_E_master-script" runs all simulation experiments.
    #
## This Script`s description
    # This script creates the treatments and sets the input values for experiment 7.
    # Exp. 10 is a wildtype simulation extended until the year 3000. All parameters are left at the observed strength.
    # This is just a vanilla extension to check migrants have the same behaviour as before.
    # There are no inputs to this script.
    # The outputs are the starting values year and replicates and a treatment matrix T.
    # Done directly through script B, this is just for the record.

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
           treatment_smooth_run = DataFrame(treat_code_Svt_BBt_Dt_Mt = ["1_1_1_1"], # Sv, BB, Dt
                       SVt = [1],
                       BBt = [1],
                       Dt  = [1],
                       Mt  = [1])

       T = treatment_smooth_run
       replicates = 20
       year = 3000
       exp_name = "exp_0-"
       filepath = "data/processed/julia_runs/Exp-0_smooth_run"

## Run Treatments
@time Treatment_reps = Treatment_loop_f(T) # 0.1 hours Smooth Run
