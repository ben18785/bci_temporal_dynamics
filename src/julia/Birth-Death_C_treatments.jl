## Script family description
    # These scripts build the functions to model the BCI population using time series data.
    # This is done using a Birth-Death model including selection for births and deaths and migration.
    # The scripts are named sequentially A, B...E and every script includes the previous script.
    # The final script "Birth-Death_E_master-script" runs all simulation experiments.
    #
## This Script`s description
    # This script implements the experimental treatments and runs replicates of each.
    # This script uses two scripts:
    # 1) the loop function defined in the script "Birth-Death_B_replicates.jl", in the same folder,
    # 2) and the experiment treatment script defined in "Birth-Death_C_treat_exp_X.jl"
    # By taking that this script runs and saves experiments for each treatment combination with n replicates.
    # The inputs are the basic simulation, replicates and treatment functions.
    # The outputs are the counts matrices for each treatment, each treatments saved with its replicates in independent files.
    #
## Author: Jerónimo Cid, follwoing my Master thesis at Imperial College London.
    # Contact details:        |                       |
    # Author;                 Supervisor;             Co-supervisor;
    # Jerónimo Cid;           Armand M. Leroi;        Ben Lambert
    # jernimo.cid19@ic.ac.uk; a.leroi@imperial.ac.uk; ben.c.lambert@gmail.com
    # date: 30/07/2021
    #
# Call the previous script (Birth-Death_B_replicates)
    include("Birth-Death_B_replicates.jl") # call the experimental parameters
    #
## FUNCTION STARTS HERE
##
 # This function runs the replicates function once for each treatment. The replicate number is specified in the following scripts
    #
function Treatment_loop_f(T) # This function concatenates and names treatment preamble
    println(exp_name, " of ", 5 ," done.")
    # T_nr, Sv, BB, Dt, Mt
    for i in size(T,1):-1:1 # T(treat_code[1],SVt[2], BBt[3], Dt[4], Mt[5]). reverse->backward loop
    # for i in 1:-1:1
        println("treatment ", i, " of ", size(T,1)," started.")
      this_treatment = Replicates_Birth_Death(replicates,year,T[i,4],T[i,3],T[i,2],T[i,5]) # loop_Moran(Dt,BBt,SVt,Mt)
        Treatment_reps = this_treatment
        # count matrix
            # Mt =  repeat([1],size(Treatment_reps,1))
            Mt =  repeat([T[i,5]],size(Treatment_reps,1)) # create Mt column
            Treatment_reps = hcat(Mt,Treatment_reps)      # concatenate Mt column with counts matrix
            rename!(Treatment_reps, Dict(:x1 => "Mt"))    # rename Mt column
                Dt = repeat([T[i,4]],size(Treatment_reps,1)) # create Dt column
                Treatment_reps = hcat(Dt,Treatment_reps)     # concatenate Dt column with counts matrix
                rename!(Treatment_reps, Dict(:x1 => "Dt"))   # rename Dt column
                    BBt =  repeat([T[i,3]],size(Treatment_reps,1)) # create BBt column
                    Treatment_reps = hcat(BBt,Treatment_reps)      # concatenate BBt column with counts matrix
                    rename!(Treatment_reps, Dict(:x1 => "BBt"))    # rename BBt column
                        SVt =  repeat([T[i,2]],size(Treatment_reps,1)) # create SVt column
                        Treatment_reps = hcat(SVt,Treatment_reps)      # concatenate SVt column with counts matrix
                        rename!(Treatment_reps, Dict(:x1 => "SVt"))    # rename SVt column
                            treatment_nr =  repeat([i],size(Treatment_reps,1))    # create T_nr column
                            Treatment_reps = hcat(treatment_nr,Treatment_reps)    # hcat T_nr column with counts
                            rename!(Treatment_reps, Dict(:x1 => "treatment_nr.")) # rename T_nr column
        filename_counts = string(exp_name,i,"_",T[i,1],".csv")
        CSV.write(joinpath(filepath, filename_counts),DataFrame(Treatment_reps))
        #
        # console printing
        println("treatment ", i, " of ", size(T,1)," done.")
    end
    println(exp_name, " of ", 5 ," done.")
end
