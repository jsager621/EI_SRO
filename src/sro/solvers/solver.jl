module SROSolvers
export oracle_solve, take_all

using FromFile
@from "../sro_problem_generation.jl" using SROProblems

include("utils.jl")
include("oracle.jl")
include("simple_heuristics.jl")
end