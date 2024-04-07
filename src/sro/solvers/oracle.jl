
using JuMP
using HiGHS
using InvertedIndices
using FromFile
@from "../sro_problem_generation.jl" using SROProblems

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
function oracle_solve(problem::SROProblem)::SROSolution
    resources = problem.resources
    v_target = problem.target.v_target

    max_value = sum([r.rolled_value for r in resources])
    knapsack_target = float(max_value - v_target)

    if knapsack_target < 0
        return SROSolution(
            Vector{SROResource}(), # TODO
            Inf,
            v_target
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