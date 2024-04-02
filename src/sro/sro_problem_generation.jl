# n_participants, copulas, distributions
# cost functions
module SROProblems
using Distributions
using Copulas
using Random

export SROResource, SROTarget, SROProblem, SROProblemInstance, instantiate_problem

# In this first version we only use a multivariate gaussian copula.

# covariance matrix with full independence
COV_12x12_INDEPENDENT = 
[
  1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
  0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
  0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
  0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
  0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
  0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0
  0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0
  0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0
  0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0
  0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0
  0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0
  0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0
]

# correlation matrix with two sets of 5 correlated variables
# and two independent variables
# variables 1-5 have covariance 0.4
# variables 8-12 have covariance 0.7
COV_12x12_5_2_5 = 
[
    1.0 0.4 0.4 0.4 0.4 0.0 0.0 0.0 0.0 0.0 0.0
    0.4 1.0 0.4 0.4 0.4 0.0 0.0 0.0 0.0 0.0 0.0
    0.4 0.4 1.0 0.4 0.4 0.0 0.0 0.0 0.0 0.0 0.0
    0.4 0.4 0.4 1.0 0.4 0.0 0.0 0.0 0.0 0.0 0.0
    0.4 0.4 0.4 0.4 1.0 0.0 0.0 0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.7 0.7 0.7
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.7 1.0 0.7 0.7
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.7 0.7 1.0 0.7
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.7 0.7 0.7 1.0
]

COV_TEST = [
    1.0 0.4 0.4 0.4 0.4 0.0 0.0 0.0 0.0 0.0 0.0
    0.4 1.0 0.4 0.4 0.4 0.0 0.0 0.0 0.0 0.0 0.0
    0.4 0.4 1.0 0.4 0.4 0.0 0.0 0.0 0.0 0.0 0.0
    0.4 0.4 0.4 1.0 0.4 0.0 0.0 0.0 0.0 0.0 0.0
    0.4 0.4 0.4 0.4 1.0 0.0 0.0 0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.9 0.9 0.9
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.9 1.0 0.9 0.9
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.9 0.9 1.0 0.9
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.9 0.9 0.9 1.0
]

struct SROResource
    values::ContinuousUnivariateDistribution
    c_selection::Float64
    c_per_kw::Float64
end

# C = GaussianCopula([
#     1.0 0.4 0.1
#     0.4 1.0 0.8
#     0.1 0.8 1.0
# ])

struct SROTarget
    p_target::Float64
    v_target::Float64
end

struct SROProblem
    resoures::Vector{SROResource}
    cov_matrix::Matrix{Float64}
    target::SROTarget
end

struct SROProblemInstance
    resoures::Vector{SROResource}
    cov_matrix::Matrix{Float64}
    target::SROTarget
    rolled_values::Vector{Float64}
end

function instantiate_problem(rng::Xoshiro, problem::SROProblem)::SROProblemInstance
    rolled_values = Vector{Float64}()
    # TODO

    return SROProblemInstance(
        problem.resoures,
        problem.cov_matrix,
        problem.target,
        rolled_values
    )
end


function main()
    rng = Xoshiro(1)

    # X₁ = Normal(10, 5)
    # X₂ = Normal(10, 5)
    # X₃ = Normal(10, 5)

    # C = GaussianCopula([
    #     1.0 0.5 -0.5
    #     0.5 1.0 -0.1
    #     -0.5 -0.1 1.0
    # ])

    # D = SklarDist(C,(X₁,X₂,X₃))
    # x = rand(rng, D,4)

    # display(x)

    cov_m = COV_12x12_5_2_5
    C = GaussianCopula(cov_m)
    dists = Vector{Normal}()
    for i in 1:size(cov_m, 1)
        push!(dists, Normal(10, 5))
    end

    dists = Tuple(dists)

    D = SklarDist(C,dists)
    x = rand(rng, D,4)
    display(x)

    println("done")
end

main()

end

