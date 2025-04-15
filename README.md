# Copula Correlated SRO with Full Information

This repository contains the model code of the Stochastic Resource Optimization (SRO) problem as submitted for publication with Springer Open Energy Informatics under the title: "Combinatorial Chance-constrained Economic Optimization of Distributed Energy Resources".

## If you want to use SRO yourself
At the moment, all pure SRO implementations are being moved to their own repository [SRO.jl](https://github.com/jsager621/SRO.jl).
This library will have cleaner implementations and better documentation for reuse.

## Running the Simulation

### Installation
To run the simulations yourself you need to instantiate the necessary Julia packages. 
This is done via the Julia REPL:

```
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.10.4 (2024-06-04)
 _/ |\__'_|_|_|\__'_|  |  
|__/                   |

(@v1.10) pkg> activate .
  Activating project at `/path/to/this/repo`

(EI_SRO) pkg>  instantiate
    [relevant packages should install now]
```

Once this is completed, each part of the paper has a corresponding executable file.

### Congestion Management Example
To generate the outputs of the congestion management example, run:
```
julia --project=. run_example_problems.jl   
```
This will output the solutions to the example problem to the console:

```
julia --project=. run_example_problems.jl                                                                           
Problem: 1
Buy All: 
2562
["WI_2", "WI_3", "WI_4"]
4393
["PV_2", "PV_3", "WI_1", "WI_3", "WI_4", "BA_1"]
Buy necessary: 
2550
["WI_2", "WI_3", "WI_4"]
2900
["PV_2", "WI_2", "WI_3", "WI_4", "BA_1"]

[...]
```

### Solution Performance Analysis
The solution performance analysis was done via the `run_benchmark.jl` script.
This script requires 5 command line arguments:

```
julia --project=. run_benchmark.jl <rng_seed> <run_name> <generator_type> <market_type> <output_subdirectory> <p_target> <n_resources> <all_algos>
```

In order, these define:
* <rng_seed> - the seed of the random number generation
* <run_name> - a name given to the runs output files
* <generator_type> - can be "n", "b", "w", "m" for Normal, Beta, Weibull or mixed scenarios, respectively.
* <market_type> - "1" for buy-all, "0" for buy-necessary
* <output_subdirectory> - subfolder of `./outputs/logs/` to save the results to
* <p_target> - target probability of the problems
* <n_resources> - number of resources per problem
* <all_algos> - "1" to include full and oracle solvers, "0" for heuristics only

Additional simulation simulation parameters like the number of problems and instances sampled and the number of samples used by the fitting-based algorithms can be edited at the top of the script file.

For convenience, all the various parameterizations used in the paper were put in a bash file and can be run via:

```
./run_paper_benchmarks.sh
```

### Runtime Comparison
Benchmarks for the runtime of the implemented algorithms can be run via:

```
julia --project=. runtime_comparison.jl
```

The results of this script are also saved to `./outputs/logs`.

## Plots
The plots used directly in the paper are included in the repository.
Box plots of the different algorithm performances were created using the `plot_results.py` script using the [seaborn](https://seaborn.pydata.org/) library.

The scripts to create the two congestion scenario plots are included in the `paper_plots` directory.
