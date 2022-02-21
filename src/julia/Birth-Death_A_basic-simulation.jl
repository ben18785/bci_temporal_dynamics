## Script family description
    # These scripts build the functions to model the BCI population using time series data.
    # This is done using a Birth-Death model including selection for births and deaths and migration.
    # The scripts are named sequentially A, B...E and every script includes the previous script.
    # The final script "Birth-Death_E_master-script" runs all simulation experiments.
    #
## This Script`s description
    # Script "Birth-Death_A_basic-function.jl" creates the basic function for one series run.
    # The inputs are four: the year (series length),Dt (drift parameter),
    # BBt (fecundity selection parameter), SVt (survivorship selection parameter), and Mt (community migration parameter).
    # The outputs are two: an abundance matrix and a counts matrix.
    #
## Author: Jerónimo Cid, follwoing my Master thesis at Imperial College London.
    # Contact details:        |                       |
    # Author;                 Supervisor;             Co-supervisor;
    # Jerónimo Cid;           Armand M. Leroi;        Ben Lambert
    # jernimo.cid19@ic.ac.uk; a.leroi@imperial.ac.uk; ben.c.lambert@gmail.com
    # date: 30/07/2021
    #
## Packages used
    #using Pkg; Pkg.add("Distributions"); Pkg.add("Random"); Pkg.add("CSV"); Pkg.add("Distributions"); Pkg.add("Distributions"); # activate to install packages if not installed
    using Distributions # load packages; Multinomial, binomial and poisson distributions
    using Random # sample
    using CSV # file loading and saving
    using DataFrames # data formats
    #
## Working directory
    # cd(joinpath(homedir(),"Desktop/simulation_selection_07"))
    # pwd()
## Data files needed
    ## Initial Frequencies
    # read file for initial frequencies
        initial_frequencies = CSV.read("data/processed/initial_frequencies.csv",DataFrame)[:,[1,3]]
        # add frequencies column
        initial_frequencies[:,:freq] = initial_frequencies[:,2]/sum(initial_frequencies[:,2])
        # remove species absent in 1982
        # these are: "Cojoba rufescens", "Cupania latifolia", "Hamelia patens", "Ternstroemia tepezapote", "Trema micrantha".
        late_comers = initial_frequencies[initial_frequencies[:,3] .== 0,[1,3]]
        x0 =  initial_frequencies[:,[1,3]] # counts not needed from now on.
        for each_late_comer in 1:size(late_comers,1) #  this loop removes species absent in 1982
            global x0 =  x0[x0[:,1] .!= late_comers[each_late_comer,1],1:end]
        end

    ## Parameter medians (BB, psa, delta)
    # read file for birth death medians
    birth_death_medians = CSV.read("data/processed/birth_death_medians.csv",DataFrame)[:,2:end]
    # remove species absent in 1982
        for each_late_comer in 1:size(late_comers,1) #  this loop removes species absent in 1982
            global birth_death_medians =  birth_death_medians[birth_death_medians[:,1] .!= late_comers[each_late_comer,1],1:end]
        end
    # Extract betas and psa from full dataframe
        B_vec_births = birth_death_medians[:,[1,2]]
        p_survive_annual = birth_death_medians[:,[1,3]]
        # delta median
        delta = CSV.read("data/processed/birth_death_delta.csv",DataFrame)[1,1]
        #
    ## parameter sample runs
    # beta births
        beta_births_sample_runs = CSV.read("data/processed/birth_death_betas.csv",DataFrame)[:,2:end]
        for each_late_comer in 1:size(late_comers,1) #  this loop removes species absent in 1982
            global beta_births_sample_runs =  beta_births_sample_runs[beta_births_sample_runs[:,1] .!= late_comers[each_late_comer,1],1:end]
        end
    # p_survive annual (psa) deaths_G
        p_s_annual_sample_runs = CSV.read("data/processed/birth_death_survive_annual.csv",DataFrame)[:,2:end]
        for each_late_comer in 1:size(late_comers,1) #  this loop removes species absent in 1982
            global p_s_annual_sample_runs =  p_s_annual_sample_runs[p_s_annual_sample_runs[:,1] .!= late_comers[each_late_comer,1],1:end]
        end
    # migration parameter (delta) sample runs
        deltas_sample_runs = CSV.read("data/processed/birth_death_delta_draws.csv",DataFrame)

    ## Marix of plausible species for migrants
        migrant_parameters = CSV.read("data/processed/population_birth_death_samples.csv",DataFrame)
        rename!(migrant_parameters, Dict(:beta => "BB_fecundity",:prob => "SV_survivorship")) # rename columns

    ##################
    # avg_offspring - average offspring per species vector
        avg_offspring_censusyear = (CSV.read("data/processed/fraction_children_born_censusyear.csv",DataFrame))
        avg_time_step = (2015-1982)/8  # 33 years covered by the time series divided by 8 time steps = 4.125


    # N Community size (N) and parameters of strength for each force (drift, selection and migration)
        N_trees = (CSV.read("data/processed/N_trees.csv",DataFrame)) # could add [:,[2,3]] to import just some columns
        # for the effective Community size (Ne) we use the harmonic mean of the total Community size each census year.
        proportion_censusyear = avg_time_step/33
        Ne = Int(round(1 / ((proportion_censusyear/N_trees[N_trees[:,1] .== 1982, 2][]) + (proportion_censusyear/N_trees[N_trees[:,1] .== 1985, 2][]) + (proportion_censusyear/N_trees[N_trees[:,1] .== 1990, 2][]) + (proportion_censusyear/N_trees[N_trees[:,1] .== 1995, 2][]) + (proportion_censusyear/N_trees[N_trees[:,1] .== 2000, 2][]) + (proportion_censusyear/N_trees[N_trees[:,1] .== 2005, 2][]) + (proportion_censusyear/N_trees[N_trees[:,1] .== 2010, 2][]) + (proportion_censusyear/N_trees[N_trees[:,1] .== 2015, 2][])))) # Ne = 83,648 trees
        N = Ne; # G = 07 # number of individual trees and number of generations (years, 2015-1982)
        year = 2015; Dt = 1; BBt = 1; SVt = 1; Mt = 1; uncertainty = "no";

## FUNCTION STARTS HERE
##
function Birth_Death_1_Simulation(year,Dt,BBt,SVt,Mt)
## Function preamble
  ## Preprocessing of Arguments
  S = size(x0[!,1],1) # how many (non-migrant) species, start 252
   new_S = S
  ## Uncertainty loop
  if uncertainty == "no"
      beta_births_new = B_vec_births[:,2] # set up new parameter vector to conserve original
      p_survive_annual_new = p_survive_annual[:,2] # ...same for p_survive_annual...
      delta_new = Mt*delta # get the actual quantile of delta now
  elseif uncertainty == "yes"
        BBr = rand(2:size(beta_births_sample_runs,2)) # random column of birth betas samples
      beta_births_new = beta_births_sample_runs[!,BBr]
      #
        PSAr = rand(2:size(p_s_annual_sample_runs,2)) # random column of psa samples
      p_survive_annual_new = p_s_annual_sample_runs[!,PSAr]
      #
        Dr = rand(1:size(deltas_sample_runs,1)) # Int between 1 and 4000 (delta random)
      delta_new = Mt.*deltas_sample_runs[Dr,1]
  end # end of uncertainty loop
  #
  non_migrant_names = x0[!,1] # original names. Dimensions in rows, columns: (252,1)
    all_names = non_migrant_names # initialise all_names with initial sp, later to hold non migrant + migrant
  ## generations
  G = 7+round(Int,(year-2015)/avg_time_step) # calculate generations from year. initial 7 uses the actual interval
  # Some examples of years and G´s used:
  # year 2015 => G = 07 + 00  = 07
  # year 2300 => G = 07 + 70  = 77
  # year 3000 => G = 07 + 239 = 246
  # year 3100 => G = 07 + 233 = 270
  ## Average p_survive_annual and beta births - switching off by averaging
      p_survive_annual_avg = similar(p_survive_annual);
      p_survive_annual_avg[!,1] = p_survive_annual[!,1];
      p_survive_annual_avg[!,2] = repeat([mean(p_survive_annual[!,2])],size(p_survive_annual,1));
      #
      B_vec_births_avg =  similar(B_vec_births);
      B_vec_births_avg[!,1] = B_vec_births[!,1];
      B_vec_births_avg[!,2] = repeat([mean(B_vec_births[!,2])],size(B_vec_births,1));
      #
  ## Initialise Dataframes to hold frequencies and counts:
  x = zeros(S,G+1) # initialise frequency matrix, row as species, column as generations
  x[:,1] = x0[!,2] # first column => first generation [FREQUENCY].
  df = DataFrame(species = String[], censusyear = Int64[], N_present = Int64[], N_born = Int64[],
   N_died = Int64[]) # DF to hold the counts, births, and deaths for every G. Not loaded but calculated
  ## looping over generations starts here
  for i in 2:G+1 # start from 2nd generation end in G+1th generation
     X=x[:, i-1] # we define X as all frequencies in the last generation
     ## Loop average offspring => to use actual offspring before 2015 and the average after 2015
     if i <= 8 # iteration 8 is the year 2015
         avg_offspring_thisG = avg_offspring_censusyear[i-1,4] # use actual avg offsp for each G
     elseif i > 8 # after 2015
         avg_offspring_thisG = mean(avg_offspring_censusyear[!,4]) # use average accross generations
     end # end of loop average avg offspring
     #
   ## DEATHS. Calculates survivors from previous G. (uses: SV rate, counts_last_G, avg_time_step)
            # Loop equalize survival => to switch off selection on mortality by equalising all survivorships
                if SVt == 0 # when differential selection survivorship is off...
            p_survive_annual_new = p_survive_annual_avg[!,2] # ...all species have the same survivorship.
                else # when selection on survivorship is on...
            p_survive_annual_new = p_survive_annual_new # ...leave survivorships as they are.
                end # end of Loop equalize survival for switching off selection on mortality
                #
            # Loop Ne (community size), to use avg comm. size after 2015
                if i <= 8 # year 2015, same as average offspring loop
            X_counts_last_G = round.(Int, X .* ([N_trees[i-1,2]].* Dt)) # obtain counts from freqs * actual comm
                elseif i > 8
            X_counts_last_G = round.(Int, X .* (Ne.* Dt)) # obtain counts from freqs * harmonic mean comm
                end # end of loop community size
                #
        # Deaths loop. Calculates for each species how many trees survived to this generation i.
        deaths_G = zeros(Int,length(p_survive_annual_new),1) # initialise empty vector of death counts
           for j in 1:length(deaths_G) # for all j species, in [COUNTS]
            # Loop average time step loop to use avg. time step after 2015
               if i <= 8 # until year 2015 (same as average offspring loop and community size loop),
                   time_step = N_trees[i,1] - N_trees[i-1,1] # ...use actual time step, year i minus year (i-1);
               elseif i > 8 # after 2015...
                   time_step = avg_time_step # ...use the average 4.125 years per census interval.
               end # end of loop average time step
               #
               # sample dead trees for species j, dead=1-survived, survival rate transformed to be per census year
               deaths_G[j] = rand(Binomial(X_counts_last_G[j],(1-p_survive_annual_new[j].^time_step)))
           end # end of deaths loop
           deaths_G = deaths_G[:,1] # this line is needed to stop deaths_G being an array of two dimensions

   ## BIRTHS. Calculates births this G from birth betas, average offspring, and counts last G.
           # Loop equalize fecundity => to switch off selection on fecundity by equalising all survivorships
               if BBt == 0 # when differential selection fecundity is off...
                   beta_births_new = B_vec_births_avg[!,2] # ...all species have the same fecundity.
               else # when selection on fecundity is on...
                   beta_births_new = beta_births_new # ...leave as is
               end # end of Loop equalize fecundity for switching off selection on fecundity
               #
           ones_vec = ones(length(beta_births_new))
           xx = (ones_vec .+ (beta_births_new)) .* X_counts_last_G # with beta on/off
           xx = xx[:,1] # to stop xx being an array of two dimensions (somehow it was)
           xx=xx/sum(xx)  # Correction scaling for multinomial [0:1] and make sum(xx) = 1
        # generate births. multinomial. conceptually, asigning total births to species according to counts and BB.
        births_G = rand(Multinomial(round(Int,sum(X_counts_last_G)*avg_offspring_thisG),xx))

   ## Total trees
        counts_G = Int.(X_counts_last_G + births_G - deaths_G) # trees on generation G = present (G-1) + births(G) - deaths(G)
        counts_G = counts_G[:,1] # to stop counts_G being an array of two dimensions (somehow it was)
           x[:,i] = counts_G # set the current generation as the COUNTS! calculated. change to freq after migration.

   ## MIGRATION. Here new migrant counts are produced allocated to new species and added to Dataframes df and x
          # Loop migration.Three cases:
             #=I) migration off
              II) mig. on and at least one migrant individual that generation
             III) mig. on and no migrant individuals generated that G =#
       if Mt == 0 # migration off (case I). Build row for this G with no migrants, append to df. X unnecessary
           censusyear = repeat([N_trees[i,1]], new_S) # census year of this generation. vector. 2 = i
           species = non_migrant_names
           this_G = DataFrame(species = non_migrant_names, censusyear = censusyear, N_present = vec(counts_G), N_born = vec(births_G), N_died = vec(deaths_G))
           append!(df, this_G)
       else # migration on (cases II and III):
           # generate, allocate, name and transform migrant counts back to frequency. Then update parameters
          # 1. Generate overall migrants
            mi = rand(Poisson((Mt*delta_new)*(Ne))) # overall Migrant Individuals (~2). migrants increase in proportion to N, not just M.
          # 2. Define number of incoming migrant species
            ms = round(Int,mi/1.333333) # from mail 23/03/21 with AL, every Migrant Sp has on avg 1.33 individuals
          # 3. Allocate overall migrants to migrant species
          if mi != 0 # migration on AND when at least one migrant (case II)
            pp = vec(repeat([1/ms],ms)) # [VECTOR] (2,1) flat Probabilities for asigning migrants to migrant sp.
            am = (Int.(rand(Multinomial(mi,pp)))) # [COUNTS] Allocated Migrants per species (2,1)
          # 4. Create the matrix (vector of zeros, vcat with am) and vcat to x [FREQUENCY]
             a = Int.(zeros(ms,i-1)) # zeros before. for i = 2; 2 - 1 = 1; (2,1)
             b = Int.(zeros(ms,G-size(a,2))) # zeros after. for G = 7; (2,6)
             mm = hcat(a,am,b) # join migrant counts to mm. mm=migrant matrix (2,8)
             x = vcat(x,mm) # stick migrant matrix to rest of matrix.
          # 5. Update beta_new, p_survive_annual_new and avg_offspring with coefficients for new species
             # the idea is to randmly choose coefficients from the matrix of plausible species
             # sampling
             idx = rand(2:size(migrant_parameters,1),ms) # random row of plausible species
             # p_survival
             migrant_p_survive_annual = migrant_parameters[idx,2] # survivorships is the second column
             p_survive_annual_new = append!(p_survive_annual_new,migrant_p_survive_annual)
             # birth betas
             migrant_birth_betas = migrant_parameters[idx,1] # betas is the first column
             beta_births_new = append!(beta_births_new,migrant_birth_betas)
             new_S = length(beta_births_new)
          # 6. Update df [COUNTS]
            counts_G = append!(counts_G,am) # update counts_G to have migrants
                N_mig_born = Vector(am) # set N_born same as N_present, as happened in Ben´s estimates
            N_born = vcat(births_G,N_mig_born)
                N_mig_died = repeat([0], length(am)) # set N_mig_died as 0 as deaths will happen in the next G
            N_died = vcat(deaths_G,N_mig_died)
            # Loop censusyear to have a column with the census year
                if i <= 8 # if year is < 2015
                    censusyear = repeat([N_trees[i,1]], new_S) # census year of this generation, eg 1985. vector. 2 = i
                elseif i > 8 # after 2015
                    censusyear = repeat([round(Int,1982+avg_time_step*i)], new_S)
                end # end of loop censusyear
            # Loop to create migrant names
                nr_migrants_so_far = length(counts_G) - size(x0,1) # how many mig. names create thus far since 1982
                migrant_names = Vector() #
                    for k in 1:nr_migrants_so_far # for every migrant sp. so far
                        push!(migrant_names, "migrant_species_$(k)")
                    end
                all_names = vcat(non_migrant_names, migrant_names) # vcat original names (252,1) to migrant names (2,1)
            species = all_names # original and migrant names
            this_G = DataFrame(species = species, censusyear = censusyear, N_present = vec(counts_G), N_born = vec(N_born), N_died = vec(N_died))
            append!(df, this_G)
        else # if migration on but no migrant sp. this_G (case III)
            # Loop censusyear to have a column with the census year
               if i <= 8 # if year is < 2015
                   censusyear = repeat([N_trees[i,1]], new_S) # census year of this generation, eg 1985. vector. 2 = i
               elseif i > 8 # after 2015
                   censusyear = repeat([round(Int,1982+avg_time_step*i)], new_S)
               end # end of loop censusyear
            # Loop to create migrant names
               nr_migrants_so_far = length(counts_G) - size(x0,1) # how many mig. names create thus far since 1982
               migrant_names = Vector() #
                   for k in 1:nr_migrants_so_far # for every migrant sp. so fa
                       push!(migrant_names, "migrant_species_$(k)")
                   end
               all_names = vcat(non_migrant_names, migrant_names) # vcat original names (252,1) to migrant names (2,1)
           species = all_names # original and migrant names
           this_G = DataFrame(species = species, censusyear = censusyear, N_present = vec(counts_G), N_born = vec(births_G), N_died = vec(deaths_G))
           append!(df, this_G)
          end # end of when at least one migrant
      end # end Loops migration
      # Pass to frequency
       x[:,i] = x[:,i] ./ sum(x[:,i]) # to convert to [FREQUENCY], also use x0
       # x[:,i] = x[:,i]              # to leave as [COUNTS],    also using c0
   ## Final touches

     # Console monitoring
     if i == 5 || i == 10 || i == 20 || i == 40 || i == 80 || i == 160
     println("Generation ", i, " of ", 1+G)
     end

 end # end of for i in 2:G+1
     # x. Create names for migrants, vcat to original names and append all names to migrant matrix
     if Mt != 0 # For cases with some migration
          migrant_names = Vector()
              for i in 1:(length(beta_births_new) - size(B_vec_births,1))
                  push!(migrant_names, "migrant_species_$(i)")
              end
          all_names = vcat(non_migrant_names, migrant_names)

          simulated_matrix = hcat(all_names, x)
          return simulated_matrix, df
      else simulated_matrix = hcat(non_migrant_names, x)
          return simulated_matrix, df
      end
     return simulated_matrix, df
end # function Moran()

   simulated_matrix, df = Birth_Death_1_Simulation(year,Dt,BBt,SVt,Mt)
   simulated_matrix
   df
