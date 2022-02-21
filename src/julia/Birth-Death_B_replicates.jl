## Script family description
    # These scripts build the functions to model the BCI population using time series data.
    # This is done using a Birth-Death model including selection for births and deaths and migration.
    # The scripts are named sequentially A, B...E and every script includes the previous script.
    # The final script "Birth-Death_E_master-script" runs all simulation experiments.
    #
## This Script`s description
    # This script uses the basic function defined in the script "Birth-Death_A_basic-function.jl", in this same folder.
    # It runs the basic function an arbitrary number of times to act as replicates.
    # The inputs are  "replicate" + the same four of the basic function (year, Dt, BBt, SVt, and Mt).
    # The output is AllSimulations: a counts matrix with simulation number labelled.

## Author: Jerónimo Cid, follwoing my Master thesis at Imperial College London.
    # Contact details:        |                       |
    # Author;                 Supervisor;             Co-supervisor;
    # Jerónimo Cid;           Armand M. Leroi;        Ben Lambert
    # jernimo.cid19@ic.ac.uk; a.leroi@imperial.ac.uk; ben.c.lambert@gmail.com
    # date: 30/07/2021
    #
# Call the previous script (Birth-Death_A)
    include("Birth-Death_A_basic-simulation.jl") # call the function
    #
## FUNCTION STARTS HERE
##
 # This function repeats the Birth-Death simulation n times (n is "replicates") and outputs:
 #  a DataFrame with simulations stacked on top of each other
 #
replicates = 2 # number of repetitions or replicates
function Replicates_Birth_Death(replicates,year,Dt,BBt,SVt,Mt) # inputs the same for seamless nesting of functions
    ## Counts matrix
    counts_1_replicate = Array{Any}(undef, replicates, 1)  # initialise empty array of arrays to hold all counts for each run
    for i in 1:replicates # do the simulation n times
        thisRun = Birth_Death_1_Simulation(year,Dt,BBt,SVt,Mt) # run first, then extract from the object, if not we end up rerunning
      ## Counts matrix
        counts_1_replicate[i] = thisRun[2] # can be 1 or 2, for freq or counts. # save the counts matrix of the current run as the ith element of the counts array
        simulation_nr   = repeat([i],size(counts_1_replicate[i],1)) # to add preamble with simulation number
        counts_1_replicate[i] = hcat(simulation_nr,counts_1_replicate[i]) # named counts matrix
        rename!(counts_1_replicate[i], Dict(:x1 => "simulation_nr")) # to name the :col simulation number
        # consolte printing
          println("repl. ", i, " of ", replicates) # to monitor progress and know where it gets stuck
    end # End of this ith run
    #
    AllSimulations = DataFrame() # to concatenate count matrices in a single DataFrame instead of array of arrays
    for j in counts_1_replicate
        j = DataFrame(j)
        AllSimulations=append!(AllSimulations, j[2:end,:])
    end
    #
    return AllSimulations
end # for counts produces array (100,1), each row is an array of (1764,5)

@time AllSimulations = Replicates_Birth_Death(replicates,year,Dt,BBt,SVt,Mt)
