using Copulas, Distributions, Random, FromFile
@from "src/sro/sro_problem_generation.jl" using SROProblems
@from "src/sro/solvers/solver.jl" using SROSolvers

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

function hello_world()
    rng = Xoshiro(1)
    X₁ = Normal(10, 5)
    X₂ = Normal(10, 5)
    X₃ = Normal(10, 5)

    C = GaussianCopula([
        1.0 0.5 -0.5
        0.5 1.0 -0.1
        -0.5 -0.1 1.0
    ])

    D = SklarDist(C,(X₁,X₂,X₃))
    x = rand(rng, D,1)

    display(x)
end

function basic_function_test()
    rng = Xoshiro(1)
    
    cov_m = COV_12x12_5_2_5
    C = GaussianCopula(cov_m)
    dists = Vector{Normal}()
    for i in 1:size(cov_m, 1)
        push!(dists, Normal(10, 5))
    end

    dists = Tuple(dists)

    D = SklarDist(C,dists)
    x = rand(rng, D,1)
    display(x)

    println("done")
end

function sro_problem_stuff()
    rng = Xoshiro(1)
    cov_m = COV_12x12_5_2_5
    resources = Vector{SROResource}()
    for i in 1:size(cov_m, 1)
        new_resource = SROResource(Normal(10, 5), 1000.0, i, i, 0)
        push!(resources, new_resource)
    end

    target = SROTarget(
        0.5,
        30000
    )

    problem = SROProblem(
        resources,
        cov_m,
        target
    )

    instantiate_problem!(problem, rng)
    return problem
end

function oracle_solver(problem::SROProblem)
    solution = oracle_solve(problem)
    println(solution.total_cost)
end

function simple_solvers(problem::SROProblem)
    solution = take_all(problem)
    println(solution.total_cost)
end




function main()
    problem = sro_problem_stuff()
    oracle_solver(problem)
    simple_solvers(problem)
end

main()