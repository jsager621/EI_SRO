
function max_value(resources)
    sum([r.rolled_value for r in resources])
end

function remaining_target(resources, v_target)
    return max(v_target - sum([r.rolled_value for r in resources]), 0)
end

function total_cost(resources)
    return sum([r.c_selection + r.rolled_value * r.c_per_w for r in resources])
end