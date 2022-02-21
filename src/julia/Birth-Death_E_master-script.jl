## Script family description
    # These scripts build the functions to model the BCI population using time series data.
    # This is done using a Birth-Death model including selection for births and deaths and migration.
    # The scripts are named sequentially A, B...E and every script includes the previous script.
    # The final script "Birth-Death_E_master-script" runs all simulation experiments.
    #
## This Script`s description - Master Script
    # This script loads everything necessary for the simulation experiments and then runs all experiments sequentially and saves the output.
    # User just needs to change their directory to the folder where they keek these scripts (line 20).
    #
## Author: Jerónimo Cid, following my Master thesis at Imperial College London.
    # Contact details:        |                       |
    # Author;                 Supervisor;             Co-supervisor;
    # Jerónimo Cid;           Armand M. Leroi;        Ben Lambert
    # jernimo.cid19@ic.ac.uk; a.leroi@imperial.ac.uk; ben.c.lambert@gmail.com
    # date: 26/09/2021
    #
## Working directory (WD)
    # local absolute directory: change as appropiate only once per script
    # directory = "C:/Users/Jeronimo/Documents/Music&documents_12_06_2021/Documentos/UNIVERSIDAD-MSc_EEC _ ImpColl/1.COURSE_MATERIALS/3.Master-Project_Summer-Term/Master_Project"
    # Set and verify WD
    # cd(directory); pwd()
## Call the scripts for each experiment in order
    include("Birth-Death_D_treat_exp_1_Wildtype_Ext.jl")
    # include("Birth-Death_D_treat_exp_3_Sel_on-off_equal.jl")
    # include("Birth-Death_D_treat_exp_4_Drift-Increase.jl")
    # include("Birth-Death_D_treat_exp_5_Drift-Reduction.jl")

    # include("Birth-Death_D_treat_exp_2_Mig_Revamp.jl") # expensive
    #
## Now all output files should be found in their respective folders in the "output" directory
