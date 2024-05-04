
using InvertedIndices

function max_value(resources)::Float64
    sum([r.rolled_value for r in resources])
end

function remaining_target(resources, v_target)::Float64
    return max(v_target - sum([r.rolled_value for r in resources]), 0)
end

function total_cost(resources)::Float64
    return sum([r.c_selection + r.rolled_value * r.c_per_w for r in resources])
end

function fit_subset(subset::Vector{Int64}, value_sample_data, cost_sample_data)
    indices = collect(1:size(value_sample_data)[1])
    not_indices = indices[Not(subset)]
    value_sample = value_sample_data[Not(not_indices), Not(not_indices)]
    cost_sample = cost_sample_data[Not(not_indices), Not(not_indices)]
    value_sum_sample = sum(value_sample, dims=1)
    cost_sum_sample = sum(cost_sample, dims=1)

    value_fit_dist = fit(Normal, value_sum_sample)
    cost_fit_dist = fit(Normal, cost_sum_sample)

    return value_fit_dist, cost_fit_dist
end

function expected_cost(value_truncated_dist, cost_truncated_dist, target)::Float64
    if 1.0 - cdf(value_truncated_dist, target.v_target) >= target.p_target
        return mean(cost_truncated_dist)
    else 
        return Inf
    end
end

function target_cost(output_set, v_target)::Float64
    if sum([r.rolled_value for r in output_set]) < v_target
        return Inf
    end

    base_cost = sum(r.c_selection for r in output_set)
    value_cost = 0.0
    remaining_value = v_target
    sorted_set = sort(output_set, by=r->r.c_per_w)

    for r in sorted_set
        if remaining_value <= r.rolled_value
            value_cost += remaining_value * r.c_per_w
            break
        end

        remaining_value -= r.rolled_value
        value_cost += r.rolled_value * r.c_per_w
    end

    return base_cost + value_cost
end