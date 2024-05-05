julia --project=. --threads=10 run_benchmark.jl 1 buy_all_normal_1 n 1
julia --project=. --threads=10 run_benchmark.jl 1 buy_all_beta_1 b 1
julia --project=. --threads=10 run_benchmark.jl 1 buy_all_weibull_1 w 1
julia --project=. --threads=10 run_benchmark.jl 1 buy_all_mixed_1 m 1

julia --project=. --threads=10 run_benchmark.jl 1 buy_nec_normal_1 n 0
julia --project=. --threads=10 run_benchmark.jl 1 buy_nec_beta_1 b 0
julia --project=. --threads=10 run_benchmark.jl 1 buy_nec_weibull_1 w 0
julia --project=. --threads=10 run_benchmark.jl 1 buy_nec_mixed_1 m 0