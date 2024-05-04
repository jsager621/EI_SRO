function take_all(problem::SROProblem; buy_all::Bool)::SROSolution
    resources = problem.resources
    v_target = problem.target.v_target

    if buy_all
        return SROSolution(
            resources,
            total_cost(resources),
            remaining_target(resources, v_target)
        )
    else
        return SROSolution(
            resources,
                    target_cost(resources, v_target),
                    remaining_target(resources, v_target)
            )
    end
end