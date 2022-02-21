# Temporal dynamics of tropical forests at Barro Colorado Island (BCI)
This repository holds the materials necessary to repeat the analysis in Cid, Lambert and Leroi (2021).

## Prerequisites
The analysis uses:

- R: for data cleaning and manipulation; for fitting statistical models to data (using mostly rstan); and for graphing
- Julia: for running simulations into the future for BCI
- BCI data: this was downloaded from X on X/mm/2019

## Rerunning the analysis
Here, we use [GNU make](https://www.gnu.org/software/make/manual/make.html) to manage our analysis pipeline. Assuming that GNU make is installed, to reproduce our analyses, open up a terminal and type:

`make`

or to run the processes in parallel (here across 3 cores):

`make -j 3`

To run only the Julia code type:

``make julia_outputs``

