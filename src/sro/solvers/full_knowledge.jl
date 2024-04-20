
using Distributions, Combinatorics, Copulas
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
function fk_truncated_normal_fit(rng, problem::SROProblem, n_samples::Int64)::SROSolution
# determine minimum required number of resources beforehand (sort by their max value)
# probably cheaper in most cases even if we only save a handful of combinations to check
# collect(powerset(resources, min_resources))

resources = problem.resources
target = problem.target
sklar_dist = get_gaussian_sklar_dist(problem)

assert_msg1 = "truncated normal solver requires all resources to be truncated with upper and lower bound"
@assert all([r.possible_values isa Truncated for r in resources]) assert_msg1

assert_msg2 = "costs must be equal in all resources"
@assert all([r.c_selection == resources[1].c_selection for r in resources]) assert_msg2
@assert all([r.c_per_w == resources[1].c_per_w for r in resources]) assert_msg2

c_selection = resources[1].c_selection
c_per_w = resources[1].c_per_w

uppers = [r.possible_values.upper for r in resources]
lowers = [r.possible_values.lower for r in resources]
upper_cum_sum = cumsum(sort(uppers, rev=true))

if upper_cum_sum[end] < target.v_target
    # no feasible solution exists
    return SROSolution(
            Vector{SROResource}(),
            Inf,
            target.v_target
    )
end

min_resources = 1
for i in eachindex(upper_cum_sum)
    min_resources = i
    if upper_cum_sum[i] > target.v_target
        break
    end
end

indices = collect(1:length(resources))
sample_data = rand(rng, sklar_dist, n_samples)

thread_best_cost = [Inf for _ in 1:Threads.nthreads()]
thread_best_set = [Vector{Int64}() for _ in 1:Threads.nthreads()]

Threads.@threads for subset in collect(powerset(indices, min_resources))
    not_indices = indices[Not(subset)]
    this_sample = sample_data[Not(not_indices), Not(not_indices)]
    this_sum_sample = sum(this_sample, dims=1)
    fit_dist = fit(Normal, this_sum_sample)

    min = sum(lowers[subset])
    max = sum(uppers[subset])
    truncated_dist = truncated(fit_dist; lower=min, upper=max)

    # viability check
    if 1.0 - cdf(truncated_dist, target.v_target) >= target.p_target
        expected_sample_cost = c_selection * length(subset) + mean(truncated_dist) * c_per_w
        if expected_sample_cost < thread_best_cost[Threads.threadid()]
            thread_best_cost[Threads.threadid()] = expected_sample_cost
            thread_best_set[Threads.threadid()] = subset
        end
    end
end

# output best solution found by a thread
best_thread_index = findmin(thread_best_cost)[2]
output_set = resources[thread_best_set[best_thread_index]]

return SROSolution(
            output_set,
            total_cost(output_set),
            remaining_target(output_set, target.v_target)
    )
end
