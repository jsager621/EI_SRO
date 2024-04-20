module SROSolvers
export oracle_solve, take_all, fk_truncated_normal_fit, pbsro_truncated_normal_fit

using FromFile
@from "../sro_problem_generation.jl" using SROProblems

include("utils.jl")
include("oracle.jl")
include("simple_heuristics.jl")
include("full_knowledge.jl")
include("metaheuristics.jl")
end