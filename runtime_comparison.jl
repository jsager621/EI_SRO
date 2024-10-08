using Copulas, Distributions, Random, FromFile, JSON, BenchmarkTools, LinearAlgebra
@from "src/sro/sro_problem_generation.jl" using SROProblems
@from "src/sro/solvers/solver.jl" using SROSolvers

THIS_DIR = @__DIR__
OUTDIR = THIS_DIR * "/outputs/logs"
# oracle_solve_buy_all(problem)
# fk_truncated_normal_fit(rng, problem, n_samples; buy_all=true)
# bpso_truncated_normal_fit(rng, problem, n_samples; buy_all=true)
# oracle_solve_buy_necessary(problem)
function random_cov_matrix(rng, size)
    mat = rand(rng, size, size)
    mat = 0.5 * (mat + mat')
    mat = mat + size * I
    return mat
end

rng = Xoshiro(1)
n_samples = 1000
max_resources = 40
oracle_cutoff = 15
fk_cutoff = 12

oracle_buy_all_means = Vector{Float64}()
oracle_buy_nec_means = Vector{Float64}()
bpso_means = Vector{Float64}()
evo_means = Vector{Float64}()
size_sampling_means = Vector{Float64}()
fk_means = Vector{Float64}()


function main()
    for i in 1:max_resources
        bpso_particles = i
        bpso_steps = i
        evo_steps = i^2
        subset_size_samples = i


        resource_set = [SROResource(
            truncated(Normal(5,5); lower=0, upper=10),
            n * 100,
            n * 10) 
            for n in 1:i
        ]

        for r in resource_set
            r.rolled_value = 5.0
        end

        target = SROTarget(
            0.8,
            2.0 * i / 2
        )

        cov_matrix = random_cov_matrix(rng, i)

        problem = SROProblem(
            resource_set,
            cov_matrix,
            target
        )

        if i <= fk_cutoff
            fk = @benchmark fk_truncated_normal_fit($rng, $problem, $n_samples; buy_all=true) samples=100
        end

        if i <= oracle_cutoff
            o_buy_nec = @benchmark oracle_solve_buy_necessary($problem) samples=100
        end

        o_buy_all = @benchmark oracle_solve_buy_all($problem) samples=100
        bpso = @benchmark bpso_truncated_normal_fit($rng, $problem, $n_samples, $bpso_particles, $bpso_steps; buy_all=true) samples=100
        evo = @benchmark one_plus_one_evo_truncated_normal_fit($rng, $problem, $n_samples, $evo_steps; buy_all=true, p_bit_flip=0.3)
        size_sampling = @benchmark subset_size_truncated_normal_fit($rng, $problem, $n_samples, $subset_size_samples; buy_all=true)
        

        if i <= fk_cutoff
            push!(fk_means, mean(fk).time)
        end

        if i <= oracle_cutoff 
            push!(oracle_buy_nec_means, mean(o_buy_nec).time)
        end
        
        push!(oracle_buy_all_means, mean(o_buy_all).time)
        push!(bpso_means, mean(bpso).time)
        push!(evo_means, mean(evo).time)
        push!(size_sampling_means, mean(size_sampling).time)
    end

    # println(oracle_buy_all_means)
    # println(oracle_buy_nec_means)
    # println(bpso_means)
    # println(fk_means)

    output = Dict(
        "oracle_buy_all" => oracle_buy_all_means,
        "oracle_buy_nec" => oracle_buy_nec_means,
        "bpso" => bpso_means,
        "evo" => evo_means,
        "size_sampling" => size_sampling_means,
        "full_approx" => fk_means
    )

    fname = OUTDIR * "/" * "runtime_benchmark" * ".json"
    open(fname, "w") do f
        json_data = JSON.json(output)
        JSON.write(f, json_data)
    end
end



main()