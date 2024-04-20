
function max_value(resources)
    sum([r.rolled_value for r in resources])
end

function remaining_target(resources, v_target)
    return max(v_target - sum([r.rolled_value for r in resources]), 0)
end

function total_cost(resources)
    return sum([r.c_selection + r.rolled_value * r.c_per_w for r in resources])
end

"""
Fits the multivariate distribution <multi_var_dist> to a truncated normal 
distribution with <min> and <max> lower and upper bounds, respectively.
Fitting is done based on the sum of <n_samples> samples.
"""
function sum_truncated_normal_fit(rng, multi_var_dist, n_samples, min, max)
    data = sum(rand(rng, multi_var_dist, n_samples), dims=1)

    # fit to normal, then at truncation limits
    # since fit is not implemented for truncated normal directly
    fit_dist = fit(Normal, data)
    return truncated(fit_dist; lower=min, upper=max)
end