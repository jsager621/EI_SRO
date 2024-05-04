
function max_value(resources)::Float64
    sum([r.rolled_value for r in resources])
end

function remaining_target(resources, v_target)::Float64
    return max(v_target - sum([r.rolled_value for r in resources]), 0)
end

function total_cost(resources)::Float64
    return sum([r.c_selection + r.rolled_value * r.c_per_w for r in resources])
end

function target_cost(resources, v_target)::Float64
    # TODO implement me
    # if not feasible cost = Inf
end