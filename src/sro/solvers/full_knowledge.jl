
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

For each possible set of resources, the sum distribution is sampled n_samples times and 
fit to a truncated normal distribution with corresponding limits to determine its value.
The same is done to approximate the distribution of costs in a set of resources.
"""
function fk_truncated_normal_fit(rng, problem::SROProblem, n_samples::Int64; buy_all::Bool)::SROSolution
    resources = problem.resources
    target = problem.target
    value_sklar_dist = get_gaussian_sklar_value_dist(problem)
    cost_sklar_dist = get_gaussian_sklar_cost_dist(problem)

    assert_msg1 = "truncated normal solver requires all resources to be truncated with upper and lower bound"
    @assert all([r.possible_values isa Truncated for r in resources]) assert_msg1

    assert_msg2 = "costs must be equal in all resources"
    @assert all([r.c_selection == resources[1].c_selection for r in resources]) assert_msg2
    @assert all([r.c_per_w == resources[1].c_per_w for r in resources]) assert_msg2

    c_selection = resources[1].c_selection
    c_per_w = resources[1].c_per_w

    uppers = [r.possible_values.upper for r in resources]
    lowers = [r.possible_values.lower for r in resources]
    cost_lowers = [r.c_selection for r in resources]
    cost_uppers = [r.possible_values.upper * r.c_per_w + r.c_selection for r in resources]
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
    value_sample_data = rand(rng, value_sklar_dist, n_samples)
    cost_sample_data = rand(rng, cost_sklar_dist, n_samples)

    thread_best_cost = [Inf for _ in 1:Threads.nthreads()]
    thread_best_set = [Vector{Int64}() for _ in 1:Threads.nthreads()]

    Threads.@threads for subset in collect(powerset(indices, min_resources))
        not_indices = indices[Not(subset)]
        value_sample = value_sample_data[Not(not_indices), Not(not_indices)]
        cost_sample = cost_sample_data[Not(not_indices), Not(not_indices)]
        value_sum_sample = sum(value_sample, dims=1)
        cost_sum_sample = sum(cost_sample, dims=1)



        value_fit_dist = fit(Normal, value_sum_sample)
        cost_fit_dist = fit(Normal, cost_sum_sample)

        value_min = sum(lowers[subset])
        value_max = sum(uppers[subset])
        value_truncated_dist = truncated(value_fit_dist; lower=value_min, upper=value_max)

        cost_min = sum(cost_lowers[subset])
        cost_max = sum(cost_uppers[subset])
        cost_truncated_dist = truncated(cost_fit_dist; lower=cost_min, upper=cost_max)

        # viability check
        if 1.0 - cdf(value_truncated_dist, target.v_target) >= target.p_target
            expected_sample_cost = mean(cost_truncated_dist)
            if expected_sample_cost < thread_best_cost[Threads.threadid()]
                thread_best_cost[Threads.threadid()] = expected_sample_cost
                thread_best_set[Threads.threadid()] = subset
            end
        end
    end

    # output best solution found by a thread
    best_thread_index = findmin(thread_best_cost)[2]
    output_set = resources[thread_best_set[best_thread_index]]

    if buy_all
        return SROSolution(
                    output_set,
                    total_cost(output_set),
                    remaining_target(output_set, target.v_target)
            )
    else
        return SROSolution(
                    output_set,
                    target_cost(output_set, target.v_target),
                    remaining_target(output_set, target.v_target)
            )
    end
end
