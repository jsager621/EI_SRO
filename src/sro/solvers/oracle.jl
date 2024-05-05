
using JuMP
using HiGHS
using InvertedIndices

"""
Solves a given instantiated SRO problem using full knowledge of the rolled_value of each resource.

Note that this SRO problem formulation guarantees that any generated value amount of
selected resources is bought.
This simplifies the optimization problem, making the oracle solution a classical
knapsack problem.

Otherwise the final cost of a selection of resources would have to be computed for each set
by ordering resources by their kw price and taking values until v_target is met.

The oracle answers the question "what is the minimum cost set to provide at least v_target value?".
This is equivalent to the max knapsack problem "what is the maximum cost set pf at most v_target value?"
assuming a solution exist (i.e. sum(v_r) >= v_target).
"""
function oracle_solve_buy_all(problem::SROProblem)::SROSolution
    resources = problem.resources
    v_target = problem.target.v_target
    knapsack_target = float(max_value(resources) - v_target)

    if knapsack_target < 0
        return SROSolution(
            resources,
            total_cost(resources),
            v_target - max_value(resources)
        )
    end

    all_weights = float([r.rolled_value for r in resources])
    profits = float([r.c_selection + r.rolled_value * r.c_per_w for r in resources])

    not_indices = solve_knapsack_problem(
        profit=profits,
        weight=all_weights,
        capacity=knapsack_target
    )

    return SROSolution(
        resources[Not(not_indices)],
        sum(profits[Not(not_indices)]),
        0
    )
end

# knapsack solver taken from:
# https://jump.dev/JuMP.jl/stable/tutorials/linear/knapsack/
function solve_knapsack_problem(;
    profit::Vector{Float64},
    weight::Vector{Float64},
    capacity::Float64,
)
    n = length(weight)
    # The profit and weight vectors must be of equal length.
    @assert length(profit) == n
    model = Model(HiGHS.Optimizer)
    set_silent(model)
    @variable(model, x[1:n], Bin)
    @objective(model, Max, profit' * x)
    @constraint(model, weight' * x <= capacity)
    optimize!(model)
    @assert is_solved_and_feasible(model)
    chosen_items = [i for i in 1:n if value(x[i]) > 0.5]
    return chosen_items
end


function oracle_solve_buy_necessary(problem::SROProblem)::SROSolution
    resources = problem.resources
    target = problem.target

    rolled_values = [r.rolled_value for r in resources]
    rv_cum_sum = cumsum(sort(rolled_values, rev=true))

    if rv_cum_sum[end] < target.v_target
        # no feasible solution exists
        return SROSolution(
                Vector{SROResource}(),
                Inf,
                target.v_target
        )
    end

    min_resources = 1
    for i in eachindex(rv_cum_sum)
        min_resources = i
        if rv_cum_sum[i] > target.v_target
            break
        end
    end

    thread_best_cost = [Inf for _ in 1:Threads.nthreads()]
    thread_best_set = [Vector{SROResource}() for _ in 1:Threads.nthreads()]

    Threads.@threads for subset in collect(powerset(resources, min_resources))
        subset_cost = target_cost(subset, target.v_target)
        if subset_cost < thread_best_cost[Threads.threadid()]
            thread_best_cost[Threads.threadid()] = subset_cost
            thread_best_set[Threads.threadid()] = subset
        end
    end

    best_thread_index = findmin(thread_best_cost)[2]
    output_set = thread_best_set[best_thread_index]
    output_cost = thread_best_cost[best_thread_index]

    return SROSolution(
                    output_set,
                    output_cost,
                    0.0
            )
end