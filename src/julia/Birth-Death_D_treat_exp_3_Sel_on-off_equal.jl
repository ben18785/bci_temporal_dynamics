## Script family description
    # These scripts build the functions to model the BCI population using time series data.
    # This is done using a Birth-Death model including selection for births and deaths and migration.
    # The scripts are named sequentially A, B...E and every script includes the previous script.
    # The final script "Birth-Death_E_master-script" runs all simulation experiments.
    #
## This Script`s description
    # This script creates the treatments and sets the input values for experiment 3.
    # Exp. 3 switches selection in births and deaths on and off by shuffling around the sp. coefficients.
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
       treatment_selection = DataFrame(treat_code_Svt_BBt_Dt_Mt = ["1_1_1_1","0_1_1_1","1_0_1_1","0_0_1_1"], # Sv, BB, Dt
                       SVt = [1,0,1,0],
                       BBt = [1,1,0,0],
                       Dt  = [1,1,1,1],
                       Mt  = [1,1,1,1])
        T = treatment_selection
        year = 3000
        replicates = 100
        exp_name = "exp_3-"
        filepath = "data/processed/julia_runs/Exp-3_Sel_on-off_equal"

## Run Treatments
 @time Treatment_reps = Treatment_loop_f(T) # 0.1 hours Selection On/Off
