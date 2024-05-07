# n_participants, copulas, distributions
# cost functions
module SROProblems
using Distributions
using Copulas
using Random

export SROResource, SROTarget, SROProblem, 
       SROSolution, instantiate_problem!, 
       best_cost_from_selection, 
       get_gaussian_sklar_value_dist,
       get_gaussian_sklar_cost_dist


"""
Resource described by a continuous distributions for value generation and a linear cost function.
The cost function is set to: c = c_selection + rolled_value * c_per_w.

possible_values - Distribution of values
c_selection - cost of selection
c_per_w - cost of each unit of rolled value
rolled_value - actual value achieved when instantiating the problem
"""
mutable struct SROResource
    possible_values::ContinuousUnivariateDistribution
    possible_costs::ContinuousUnivariateDistribution
    c_selection::Float64
    c_per_w::Float64
    rolled_value::Float64 # v in w
    name::String

    function SROResource(possible_values, c_selection, c_per_w)
        v_low = possible_values.lower
        v_up = possible_values.upper
        c_low = c_selection
        c_up = c_selection + c_per_w * v_up

        v_range = v_up - v_low
        c_range = c_up - c_low
        scale_factor = c_range/v_range

        possible_costs = possible_values * scale_factor + c_low - v_low * scale_factor

        return new(
            possible_values,
            possible_costs,
            c_selection,
            c_per_w,
            0.0,
            ""
        )
    end

    function SROResource(possible_values, c_selection, c_per_w, name)
        v_low = possible_values.lower
        v_up = possible_values.upper
        c_low = c_selection
        c_up = c_selection + c_per_w * v_up

        v_range = v_up - v_low
        c_range = c_up - c_low
        scale_factor = c_range/v_range

        possible_costs = possible_values * scale_factor + c_low - v_low * scale_factor

        return new(
            possible_values,
            possible_costs,
            c_selection,
            c_per_w,
            0.0,
            name
        )
    end
end

struct SROTarget
    p_target::Float64
    v_target::Float64
end

struct SROSolution
    chosen_resources::Vector{SROResource}
    cost::Float64
    v_remaining::Float64
end

"""
Covariance matrix gives the pairwise covariances for each resources
marginal distributions.
Values are assigned by index in the resource vector, so resource at index
i corresponds to entries in row/column i in the covariance matrix.
"""
mutable struct SROProblem
    resources::Vector{SROResource}
    cov_matrix::Matrix{Float64}
    target::SROTarget
end

"""
Roll values for each resource in the problem set, accounting for their marginal
distributions and covariance matrix.
If rolled_value is already set for a resource, this function will override it.
"""
function instantiate_problem!(problem::SROProblem, rng::Xoshiro=Xoshiro())::Nothing
    d = get_gaussian_sklar_value_dist(problem)
    rolled_values = rand(rng, d,1)

    for i in eachindex(rolled_values)
        problem.resources[i].rolled_value = rolled_values[i]
    end

    return nothing
end

function get_gaussian_sklar_value_dist(problem::SROProblem)::SklarDist
    cov_matrix = problem.cov_matrix
    resources = problem.resources

    marginals = tuple([r.possible_values for r in resources]...)
    c = GaussianCopula(cov_matrix)
    return SklarDist(c,marginals)
end

function get_gaussian_sklar_cost_dist(problem::SROProblem)::SklarDist
    cov_matrix = problem.cov_matrix
    resources = problem.resources

    marginals = tuple([r.possible_costs for r in resources]...)
    c = GaussianCopula(cov_matrix)
    return SklarDist(c,marginals)
end

function best_cost_from_selection(target::SROTarget, selected_resources::Vector{SROResource})::Float64
    v_remaining = target.v_target
    total_cost = sum([r.c_selection for r in selected_resources])

    # sort resources by their c_per_kw from low to high
    sorted_resources = sort(selected_resources, by=(r->r.c_per_kw))

    # select kw from them up to their generated amount in this order until target is met
    for r in sorted_resources
        if v_remaining >= r.rolled_value
            total_cost += r.c_per_kw * r.rolled_value
            v_remaining -= r.rolled_value
        else
            total_cost += r.c_per_kw * v_remaining
            break
        end
    end

    return total_cost
end

end

