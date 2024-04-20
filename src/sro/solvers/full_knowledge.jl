
"""
Sampling-based solver using full information on the multivariate distribution of resources.
Identifies the set of resources with minimal expected cost and P(v_target) > p_target.

Since the sum distribution of resources is no easily derived analytically in general,
this makes a number of simplifying assumptions and uses numerical methods to approximate
the sum distribution.

The simplifying assumptions are:
- All resource distributions are truncated with both an upper and lower bound.
- The PDF of the resources is a truncated normal distribution.
- c_selection and c_per_w are equal on all resources.

For each possible set of resources, the sum distribution is sampled n_samples times and 
fit to a truncated normal distribution with corresponding limits to determine its value.
"""
function fk_truncated_normal_fit(problem::SROProblem, n_samples::Int64)::SROSolution
# determine minimum required number of resources beforehand (sort by their max value)
# probably cheaper in most cases even if we only save a handful of combinations to check
# collect(powerset(resources, min_resources))
end
