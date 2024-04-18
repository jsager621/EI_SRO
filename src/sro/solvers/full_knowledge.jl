
"""
Solver using full information on the multivariate distribution of resources.
Identifies the set of resources with minimal expected cost and P(v_target) > p_target.

Since the sum distribution of resources is no easily derived analytically in general,
this makes a number of simplifying assumptions and uses numerical methods to approximate
the sum distribution.

The simplifying assumptions are:
- All resource distributions are truncated with both an upper and lower bound.
- The PDF of the resources is a truncated normal distribution.
- c_selection and c_per_w are equal on all resources.
"""
function simplified_full_knowledge_solve(problem::SROProblem)::SROSolution
    
end