using Copulas, Distributions, Random, FromFile, JSON, LinearAlgebra
@from "src/sro/sro_problem_generation.jl" using SROProblems
@from "src/sro/solvers/solver.jl" using SROSolvers


PV = 0.8
WI = 0.6
BA = 0.0


COV_MAT = [
    1.0 PV PV PV 0 0 0 0 0 0 0 0
    PV 1.0 PV PV 0 0 0 0 0 0 0 0 
    PV PV 1.0 PV 0 0 0 0 0 0 0 0
    PV PV PV 1.0 0 0 0 0 0 0 0 0
    0 0 0 0 1.0 WI WI WI 0 0 0 0
    0 0 0 0 WI 1.0 WI WI 0 0 0 0 
    0 0 0 0 WI WI 1.0 WI 0 0 0 0
    0 0 0 0 WI WI WI 1.0 0 0 0 0
    0 0 0 0 0 0 0 0 1.0 BA BA BA
    0 0 0 0 0 0 0 0 BA 1.0 BA BA
    0 0 0 0 0 0 0 0 BA BA 1.0 BA
    0 0 0 0 0 0 0 0 BA BA BA 1.0
]


function main()
    # 1-4 -> PV
    # 5-8 -> Wind
    # 9-12 -> Bat
    problem_resources = Vector{SROResource}()
    for j in 1:12
        new_resource = SROResource(
            truncated(Normal(5,5); lower=0, upper=10),
            1,
            1,
        )
        push!(problem_resources, new_resource)
    end

    target = SROTarget(0.8, 10)

    new_problem = SROProblem(
            problem_resources,
            COV_MAT,
            target
        )
end



main()