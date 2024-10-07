using Copulas, Distributions, Random, FromFile, JSON, LinearAlgebra
@from "src/sro/sro_problem_generation.jl" using SROProblems
@from "src/sro/solvers/solver.jl" using SROSolvers

P_TARGET::Float64 = 0.8
n_resources::Int64 = 10
slow_algos::Bool = true

const n_problems::Int64 = 100
const n_instantiations::Int64 = 100
const n_samples::Int64 = 1000

const c_selection_lower::Int64 = 500
const c_selection_upper::Int64 = 1000
const c_per_w_lower::Int64 = 2
const c_per_w_upper::Int64 = 5

const THIS_DIR::String = @__DIR__
const OUTDIR::String = THIS_DIR * "/outputs/logs"


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
    p_target = P_TARGET
    target = SROTarget(p_target, v_target)

    resource_lower = 0.0
    resource_upper = 250.0

    for i in 1:n_problems
        c_selection = rand(rng) * (c_selection_upper - c_selection_lower) + c_selection_lower
        c_per_w = rand(rng) * (c_per_w_upper - c_per_w_lower) + c_per_w_lower

        offset = (i - 1) * n_resources
        problem_resources = Vector{SROResource}()

        for j in 1:n_resources
            resource_dist = truncated(Normal(resource_means[offset+j], resource_stds[offset+j]); lower=resource_lower, upper=resource_upper)
            new_resource = SROResource(
                resource_dist,
                c_selection,
                c_per_w,
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
    problems = Vector{SROProblem}()

    total_resources = n_problems * n_resources

    mean_lower = 50.0
    mean_upper = 150.0
    mean_mean = 100.0
    mean_std = 60.0
    mean_dist = truncated(Normal(mean_mean, mean_std); lower=mean_lower, upper=mean_upper)
    resource_means = vec(rand(rng, mean_dist, total_resources))

    v_target = n_resources * mean_mean / 2
    p_target = P_TARGET
    target = SROTarget(p_target, v_target)

    resource_lower = 0.0
    resource_upper = 250.0

    for i in 1:n_problems
        c_selection = rand(rng) * (c_selection_upper - c_selection_lower) + c_selection_lower
        c_per_w = rand(rng) * (c_per_w_upper - c_per_w_lower) + c_per_w_lower

        offset = (i - 1) * n_resources
        problem_resources = Vector{SROResource}()

        for j in 1:n_resources

            # make a beta distribution shifted to the expected mean and truncated
            beta_dist = Beta(2,4)
            # shift to desired mean
            shifted_dist = beta_dist * resource_means[offset+j] / mean(beta_dist)
            # truncate
            resource_dist = truncated(shifted_dist; lower=resource_lower, upper=resource_upper)

            new_resource = SROResource(
                resource_dist,
                c_selection,
                c_per_w,
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

function make_weibull_problems(rng, n_problems)
    problems = Vector{SROProblem}()

    total_resources = n_problems * n_resources

    mean_lower = 50.0
    mean_upper = 150.0
    mean_mean = 100.0
    mean_std = 60.0
    mean_dist = truncated(Normal(mean_mean, mean_std); lower=mean_lower, upper=mean_upper)
    resource_means = vec(rand(rng, mean_dist, total_resources))

    v_target = n_resources * mean_mean / 2
    p_target = P_TARGET
    target = SROTarget(p_target, v_target)

    resource_lower = 0.0
    resource_upper = 250.0

    for i in 1:n_problems
        c_selection = rand(rng) * (c_selection_upper - c_selection_lower) + c_selection_lower
        c_per_w = rand(rng) * (c_per_w_upper - c_per_w_lower) + c_per_w_lower

        offset = (i - 1) * n_resources
        problem_resources = Vector{SROResource}()

        for j in 1:n_resources

            # make a beta distribution shifted to the expected mean and truncated
            weibull_dist = Weibull(1.5, 1)
            # shift to desired mean
            shifted_dist = weibull_dist * resource_means[offset+j] / mean(weibull_dist)
            # truncate
            resource_dist = truncated(shifted_dist; lower=resource_lower, upper=resource_upper)
            
            new_resource = SROResource(
                resource_dist,
                c_selection,
                c_per_w,
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

function run_buy_all_problem_set(rng, problem_set, n_instantiations)
    output = Dict{String,Any}()

    Threads.@threads for (i, problem) in collect(enumerate(problem_set))
        output[string(i)] = Dict{String,Any}()

        instantiate_problem!(problem, rng)

        if slow_algos
            fk_truncated_solution = fk_truncated_normal_fit(rng, problem, n_samples; buy_all=true)
            fk_truncated_costs = zeros(Float64, n_instantiations)
            oracle_costs = zeros(Float64, n_instantiations)
            oracle_v_remaining = zeros(Float64, n_instantiations)
            fk_truncated_v_remaining = zeros(Float64, n_instantiations)
        end

        pso_solution = bpso_truncated_normal_fit(rng, problem, n_samples; buy_all=true)
        pso_costs = zeros(Float64, n_instantiations)
        
        take_all_costs = zeros(Float64, n_instantiations)

        pso_v_remaining = zeros(Float64, n_instantiations)
        take_all_v_remaining = zeros(Float64, n_instantiations)

        # NOTE: we abuse the fact here that resource subsets are shared by reference
        for i in 1:n_instantiations
            instantiate_problem!(problem, rng)

            if slow_algos
                oracle_solution = oracle_solve_buy_all(problem)
                oracle_costs[i] = oracle_solution.cost
                fk_truncated_costs[i] = total_cost(fk_truncated_solution.chosen_resources)
                oracle_v_remaining[i] = oracle_solution.v_remaining
                fk_truncated_v_remaining[i] = remaining_target(fk_truncated_solution.chosen_resources, problem.target.v_target)
            end
            
            pso_costs[i] = total_cost(pso_solution.chosen_resources)
            pso_v_remaining[i] = remaining_target(pso_solution.chosen_resources, problem.target.v_target)

            take_all_costs[i] = total_cost(problem.resources)
            take_all_v_remaining[i] = remaining_target(problem.resources, problem.target.v_target)
        end

        if slow_algos
            output[string(i)]["fk_truncated"] = (fk_truncated_costs, fk_truncated_v_remaining)
            output[string(i)]["oracle"] = (oracle_costs, oracle_v_remaining)
        end
        
        output[string(i)]["pso"] = (pso_costs, pso_v_remaining)
        output[string(i)]["take_all"] = (take_all_costs, take_all_v_remaining)
    end

    return output
end

function run_buy_necessary_problem_set(rng, problem_set, n_instantiations)
    output = Dict{String,Any}()

    Threads.@threads for (i, problem) in collect(enumerate(problem_set))
        v_target = problem.target.v_target
        output[string(i)] = Dict{String,Any}()
        instantiate_problem!(problem, rng)

        if slow_algos
            fk_truncated_solution = fk_truncated_normal_fit(rng, problem, n_samples; buy_all=true)
            fk_truncated_costs = zeros(Float64, n_instantiations)
            oracle_costs = zeros(Float64, n_instantiations)
            oracle_v_remaining = zeros(Float64, n_instantiations)
            fk_truncated_v_remaining = zeros(Float64, n_instantiations)
        end
        
        pso_solution = bpso_truncated_normal_fit(rng, problem, n_samples; buy_all=true)

        pso_costs = zeros(Float64, n_instantiations)
        take_all_costs = zeros(Float64, n_instantiations)

        pso_v_remaining = zeros(Float64, n_instantiations)
        take_all_v_remaining = zeros(Float64, n_instantiations)

        # NOTE: we abuse the fact here that resource subsets are shared by reference
        for i in 1:n_instantiations
            instantiate_problem!(problem, rng)

            if slow_algos
                oracle_solution = oracle_solve_buy_necessary(problem)
                oracle_costs[i] = oracle_solution.cost
                fk_truncated_costs[i] = target_cost(fk_truncated_solution.chosen_resources, v_target)
                oracle_v_remaining[i] = oracle_solution.v_remaining
                fk_truncated_v_remaining[i] = remaining_target(fk_truncated_solution.chosen_resources, problem.target.v_target)
            end
            
            pso_costs[i] = target_cost(pso_solution.chosen_resources, v_target)
            pso_v_remaining[i] = remaining_target(pso_solution.chosen_resources, problem.target.v_target)

            take_all_costs[i] = target_cost(problem.resources, v_target)
            take_all_v_remaining[i] = remaining_target(problem.resources, problem.target.v_target)
        end

        if slow_algos
            output[string(i)]["fk_truncated"] = (fk_truncated_costs, fk_truncated_v_remaining)
            output[string(i)]["oracle"] = (oracle_costs, oracle_v_remaining)
        end
        
        output[string(i)]["pso"] = (pso_costs, pso_v_remaining)
        output[string(i)]["take_all"] = (take_all_costs, take_all_v_remaining)
    end

    return output
end

function save_results(results, dir_name, run_name)
    run_dir = OUTDIR * "/" * dir_name * "/"

    if !isdir(run_dir)
        mkdir(run_dir)
    end

    fname = run_dir * run_name * ".json"
    open(fname, "w") do f
        json_data = JSON.json(results)
        JSON.write(f, json_data)
    end
end

function main()
    @assert length(ARGS) > 5 "Missing command line args."
    seed = parse(Int64, ARGS[1])
    run_name = ARGS[2]
    gen_type = ARGS[3]
    buy_all = Bool(parse(Int64, ARGS[4]))
    dir_name = ARGS[5]

    global P_TARGET = parse(Float64, ARGS[6])
    global n_resources = parse(Int64, ARGS[7])
    global slow_algos = Bool(parse(Int64, ARGS[8]))

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

    if buy_all
        results = run_buy_all_problem_set(rng, problems, n_instantiations)
    else
        results = run_buy_necessary_problem_set(rng, problems, n_instantiations)
    end
    save_results(results, dir_name, run_name)

    return nothing
end


@time main()