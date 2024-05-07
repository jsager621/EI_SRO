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
    rng = Xoshiro(1)

    # 1-4 -> PV
    # 5-8 -> Wind
    # 9-12 -> Bat
    problem_resources = Vector{Vector{SROResource}}()

    PV_C_SEL = 50
    PV_C_PER_W = 0.1

    WI_C_SEL = 100
    WI_C_PER_W = 0.1

    BA_C_SEL = 300
    BA_C_PER_W = 0.3

    PV_STD = 0.1
    WI_STD = 0.2
    BA_STD = 0.05
    RESOURCE_SIZES = [6000, 7000, 8000, 9000]

    pv_levels = [0.1, 0.9, 0.9, 0.1]
    wi_levels = [0.9, 0.8, 0.2, 0.2]
    ba_levels = [0.8, 0.8, 0.8, 0.8]


    for p in 1:4
        resources = Vector{SROResource}()
        for i in 1:4
            # PV resources
            if pv_levels[i] == 0
                dist = truncated(Normal(0,0); lower=0, upper=0)
            else
                pv_mean = pv_levels[p] * RESOURCE_SIZES[i]
                pv_std = pv_mean * PV_STD
                pv_upper = RESOURCE_SIZES[i]
                dist = truncated(Normal(pv_mean, pv_std); lower=0, upper=pv_upper) 
            end

            new_resource = SROResource(
                dist,
                PV_C_SEL,
                PV_C_PER_W,
                "PV_" * string(i)
                )
            push!(resources, new_resource)
        end
        for i in 1:4
            # Wind resources
            wi_mean = wi_levels[p] * RESOURCE_SIZES[i]
            wi_std = wi_mean * WI_STD
            wi_upper = RESOURCE_SIZES[i]
            dist = truncated(Normal(wi_mean, wi_std); lower=0, upper=wi_upper) 
            new_resource = SROResource(
                dist,
                WI_C_SEL,
                WI_C_PER_W,
                "WI_" * string(i)
                )
            push!(resources, new_resource)
        end
        for i in 1:4
            # bat resources
            ba_mean = ba_levels[p] * RESOURCE_SIZES[i]
            ba_std = ba_mean * BA_STD
            ba_upper = RESOURCE_SIZES[i]
            dist = truncated(Normal(ba_mean, ba_std); lower=0, upper=ba_upper) 
            new_resource = SROResource(
                dist,
                BA_C_SEL,
                BA_C_PER_W,
                "BA_" * string(i)
                )
            push!(resources, new_resource)
        end
        push!(problem_resources, resources)
    end

    p_target = 0.8
    targets = [
        SROTarget(p_target, 22500),
        SROTarget(p_target, 22500),
        SROTarget(p_target, 22500),
        SROTarget(p_target, 22500)
    ]

    problems = Vector{SROProblem}()
    for i in 1:4
        new_problem = SROProblem(
            problem_resources[i],
            COV_MAT,
            targets[i]
        )
        instantiate_problem!(new_problem, rng)
        push!(problems, new_problem)
    end

    n_samples = 1000

    for (i, problem) in enumerate(problems)
        o_ba = oracle_solve_buy_all(problem)
        o_bn = oracle_solve_buy_necessary(problem)
        bpso_ba = bpso_truncated_normal_fit(rng, problem, n_samples; buy_all=true)
        bpso_bn = bpso_truncated_normal_fit(rng, problem, n_samples; buy_all=false)

        println("Problem: ", i)
        println("Buy All: ")
        println(round(Int, o_ba.cost))
        println([x.name for x in o_ba.chosen_resources])

        println(round(Int, bpso_ba.cost))
        println([x.name for x in bpso_ba.chosen_resources])

        println("Buy necessary: ")
        println(round(Int, o_bn.cost))
        println([x.name for x in o_bn.chosen_resources])

        println(round(Int, bpso_bn.cost))
        println([x.name for x in bpso_bn.chosen_resources])

        println("----------------------------")
    end
    
end



main()