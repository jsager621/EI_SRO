using Copulas, Distributions, Random, FromFile, JSON, LinearAlgebra
@from "src/sro/sro_problem_generation.jl" using SROProblems
@from "src/sro/solvers/solver.jl" using SROSolvers

n_problems = 100
n_instantiations = 1000
n_resources = 10
c_selection = 100
c_per_w = 10
n_samples = 1000

THIS_DIR = @__DIR__
OUTDIR = THIS_DIR * "/outputs/logs"

function random_cov_matrix(rng, size)
    mat = rand(rng, size, size)
    mat = 0.5 * (mat + mat')
    mat = mat + size * I
    return mat
end

function make_normal_problems(rng, n_problems)
    problems = Vector{SROProblem}()

    total_resources = n_problems * n_resources

    mean_lower = 50.0
    mean_upper = 150.0
    mean_mean = 100.0
    mean_std = 60.0
    mean_dist = truncated(Normal(mean_mean, mean_std); lower=mean_lower, upper=mean_upper)
    resource_means = vec(rand(rng, mean_dist, total_resources))

    std_lower = 10.0
    std_upper = 50.0
    std_mean = 25.0
    std_std = 10.0
    std_dist = truncated(Normal(std_mean, std_std); lower=std_lower, upper=std_upper)
    resource_stds = vec(rand(rng, std_dist, total_resources))

    v_target = n_resources * mean_mean / 2
    p_target = 0.8
    target = SROTarget(p_target, v_target)

    resource_lower = 0.0
    resource_upper = 250.0

    for i in 1:n_problems
        offset = (i - 1) * n_resources
        problem_resources = Vector{SROResource}()

        for j in 1:n_resources
            resource_dist = truncated(Normal(resource_means[offset + j], resource_stds[offset + j]); lower=resource_lower, upper=resource_upper)
            new_resource = SROResource(
                resource_dist,
                c_selection,
                c_per_w,
                0.0
            )
            push!(problem_resources, new_resource)
        end

        cov_matrix = random_cov_matrix(rng, n_resources)

        new_problem = SROProblem(
            problem_resources,
            cov_matrix,
            target
        )

        push!(problems, new_problem)
    end

    return problems
end

function make_beta_problems(rng, n_problems)

end

function make_weibull_problems(rng, n_problems)

end

function make_mixed_problems(rng, n_problems)
    normals = make_normal_problems(rng, n_problems ÷ 3)
    beta = make_beta_problems(rng, n_problems ÷ 3)
    weibull = make_weibull_problems(rng, n_problems ÷ 3)
    return vcat(normals, beta, weibull)
end

function make_problem_sets(rng, n_problems)
    normals = make_normal_problems(rng, n_problems)
    beta = make_beta_problems(rng, n_problems)
    weibull = make_weibull_problems(rng, n_problems)
    mixed = make_mixed_problems(rng, n_problems)
    return (normals, beta, weibull, mixed)
end

function run_problem_set(rng, problem_set, n_instantiations)
    output = Dict{String, Any}()

    for (i, problem) in enumerate(problem_set)
        output[string(i)] = Dict{String, Any}()

        instantiate_problem!(problem, rng)
        fk_truncated_solution = fk_truncated_normal_fit(rng, problem, n_samples)
        pso_solution = bpso_truncated_normal_fit(rng, problem, n_samples)

        fk_truncated_costs = zeros(Float64, n_instantiations)
        pso_costs = zeros(Float64, n_instantiations)
        oracle_costs = zeros(Float64, n_instantiations)

        oracle_n_no_remaining = 0
        fk_truncated_n_no_remaining = 0
        pso_n_no_remaining = 0

        # NOTE: we abuse the fact here that resource subsets are shared by reference
        for i in 1:n_instantiations
            instantiate_problem!(problem, rng)
            oracle_solution = oracle_solve(problem)

            oracle_costs[i] = oracle_solution.total_cost
            fk_truncated_costs[i] = total_cost(fk_truncated_solution.chosen_resources)
            pso_costs[i] = total_cost(pso_solution.chosen_resources)

            if oracle_solution.v_remaining == 0
                oracle_n_no_remaining += 1
            end

            if remaining_target(fk_truncated_solution.chosen_resources, problem.target.v_target) == 0
                fk_truncated_n_no_remaining += 1
            end

            if remaining_target(pso_solution.chosen_resources, problem.target.v_target) == 0
                pso_n_no_remaining += 1
            end
        end

        output[string(i)]["fk_truncated"] = (fk_truncated_costs, mean(fk_truncated_costs), fk_truncated_n_no_remaining)
        output[string(i)]["pso"] = (pso_costs, mean(pso_costs), pso_n_no_remaining)
        output[string(i)]["oracle"] = (oracle_costs, mean(oracle_costs), oracle_n_no_remaining)
    end

    return output
end

function save_results(results, run_name)
    fname = OUTDIR * "/" * run_name * ".json"
    open(fname, "w") do f
        json_data = JSON.json(results)
        JSON.write(f, json_data)
    end
end

function main()
    @assert length(ARGS) > 2 "Missing command line args."
    seed = parse(Int64, ARGS[1])
    run_name = ARGS[2]
    gen_type = ARGS[3]

    name_to_gen_function = Dict(
        "n" => make_normal_problems,
        "b" => make_beta_problems,
        "w" => make_weibull_problems,
        "m" => make_mixed_problems 
    )

    gen_func = name_to_gen_function[gen_type]

    rng = Xoshiro(seed)
    
    # normals, beta, weibull, mixed = make_problem_sets(rng, n_problems)
    problems = gen_func(rng, n_problems)
    results = run_problem_set(rng, problems, n_instantiations)
    save_results(results, run_name)

    return nothing
end


main()