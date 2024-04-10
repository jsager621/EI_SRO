function take_all(problem::SROProblem)::SROSolution
    resources = problem.resources
    v_target = problem.target.v_target

    return SROSolution(
        resources,
        total_cost(resources),
        remaining_target(resources, v_target)
    )
end