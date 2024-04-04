# n_participants, copulas, distributions
# cost functions
module SROProblems
using Distributions
using Copulas
using Random

export SROResource, SROTarget, SROProblem, instantiate_problem!, best_cost_from_selection

mutable struct SROResource
    possible_values::ContinuousUnivariateDistribution
    c_selection::Float64
    c_per_kw::Float64
    rolled_value::Float64
end

struct SROTarget
    p_target::Float64
    v_target::Float64
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
    cov_matrix = problem.cov_matrix
    resources = problem.resources

    marginals = tuple([r.possible_values for r in resources]...)
    c = GaussianCopula(cov_matrix)
    d = SklarDist(c,marginals)
    rolled_values = rand(rng, d,1)

    for i in eachindex(rolled_values)
        problem.resources[i].rolled_value = rolled_values[i]
    end

    return nothing
end

function best_cost_from_selection(target::SROTarget, selected_resources::Vector{SROResource})::Float64
    v_target = target.v_target
    # TODO

    # sort resources by their c_per_kw from low to high

    # select kw from them up to their generated amount in this order until target is met
end

end

