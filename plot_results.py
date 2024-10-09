import json
import seaborn as sns
import os
import sys
from pathlib import Path

this_dir = os.path.dirname(os.path.realpath(__file__))
log_dir = os.path.join(this_dir, "outputs", "logs")
plot_dir = os.path.join(this_dir, "outputs", "plots")

def read_scenario(scenario_dir, scenario_name):
    fname = os.path.join(scenario_dir, scenario_name + ".json", )

    with open(fname, "r") as f:
        data = json.load(f)
        return data

def plot_scenario_data(data, scenario_dir_name, scenario_name):
    out_dir = os.path.join(plot_dir, scenario_dir_name)
    if not os.path.exists(out_dir):
        os.mkdir(out_dir)
    out_fname = os.path.join(out_dir, scenario_name + ".png")

    result_costs = {}
    result_v_remaining = {}

    # find algo names
    first = data["1"]
    for algo_name in first.keys():
        result_costs[algo_name] = []
        result_v_remaining[algo_name] = []

    for algo_name in result_costs.keys():
        for problem_i in data.keys():
            result_costs[algo_name] += data[problem_i][algo_name][0]
            result_v_remaining[algo_name] += data[problem_i][algo_name][1]

    # for k in result_n_remaining.keys():
    #     print(k)
    #     print(result_n_remaining[k])


    # only add to the cost dataset if everyone got a valid solution
    # otherwise we get misleading total costs!
    filtered_costs = {}
    data_length = 0

    for algo_name in result_costs.keys():
        filtered_costs[algo_name] = []
        data_length = len(result_costs[algo_name])

    for i in range(data_length):
        if all([result_v_remaining[a][i] == 0 for a in result_v_remaining.keys()]):
            for algo_name in result_costs.keys():
                filtered_costs[algo_name].append(result_costs[algo_name][i])

    # rename for plots
    if "size_sampling" in filtered_costs:
        filtered_costs["by_size"] = filtered_costs["size_sampling"]
        del(filtered_costs["size_sampling"])

    if "fk_truncated" in filtered_costs:
        filtered_costs["full"] = filtered_costs["fk_truncated"]
        del(filtered_costs["fk_truncated"])

    # order for plots
    col_names = list(filtered_costs.keys())

    # third
    if "full" in col_names:
        col_names.remove("full")
        col_names.insert(0, "full")

    # second
    if "oracle" in col_names:
        col_names.remove("oracle")
        col_names.insert(0, "oracle")

    # first
    if "take_all" in col_names:
        col_names.remove("take_all")
        col_names.insert(0, "take_all")

    # seaborn.boxplot({"one": data, "two": data, "three": data}).set(xlabel="algo", ylabel="cost")
    plot = sns.boxplot(filtered_costs, order=col_names)
    plot.set(xlabel="algorithm", ylabel="cumulative result costs")
    plot.set(title=scenario_name[:-2])
    fig = plot.get_figure()
    fig.savefig(out_fname)
    fig.clf()


def print_success_rates(scenario_dir):
    files = os.listdir(scenario_dir)
    scenarios = []
    for f in files:
        if "runtime" in f:
            continue
        name = Path(f).stem
        data = read_scenario(scenario_dir, name)
        scenarios.append(data)

    algo_counters = {
        "evo": 0,
        "by_size": 0,
        "pso": 0,
        "fk_truncated": 0
    }

    for scenario in scenarios:
        for i_problem in scenario.keys():
            evo_data = scenario[i_problem]["evo_30"]
            by_size_data = scenario[i_problem]["size_sampling"]
            bpso_data = scenario[i_problem]["pso"]
            if "fk_truncated" in scenario[i_problem].keys():
                full_data = scenario[i_problem]["fk_truncated"]
            # oracle_data = scenario[i_problem]["oracle"]

            evo_successes = len([x for x in evo_data[1] if x == 0])
            by_size_successes = len([x for x in by_size_data[1] if x == 0])
            bpso_successes = len([x for x in bpso_data[1] if x == 0])

            if "fk_truncated" in scenario[i_problem].keys():
                full_successes = len([x for x in full_data[1] if x == 0])

            algo_counters["evo"] += evo_successes
            algo_counters["by_size"] += by_size_successes
            algo_counters["pso"] += bpso_successes

            if "fk_truncated" in scenario[i_problem].keys():
                algo_counters["fk_truncated"] += full_successes

    print(algo_counters)
    print("evo: ", algo_counters["evo"] / 80000)
    print("by_size: ", algo_counters["by_size"] / 80000)
    print("pso: ", algo_counters["pso"] / 80000)
    print("fk_truncated: ", algo_counters["fk_truncated"] / 80000)

def print_help():
    print("Please specify scenario dir and name as command line args.")
    print("""
    Usage:
    python plot_results.py <scenario_dir_name> <scenario_name>

    <scenario_dir_name> - subfolder of ./outputs/logs/ where the log file to plot is located
    <scenario_name> - log file with the data to plot

    Special inputs:
    <scenario_name> == "all" --- plots all files in the specified <scenario_dir_name>
    <scneario_name> == "success_rates" --- does not plot and instead outputs success rates of the algorithms
    """)

def main():
    if len(sys.argv) < 3:
        print_help()
        return

    scenario_dir_name = sys.argv[1]
    scenario_name = sys.argv[2]
    scenario_dir = os.path.join(log_dir, scenario_dir_name)

    if scenario_name == "all":
        files = os.listdir(scenario_dir)
        for f in files:
            if "runtime" in f:
                continue
            name = Path(f).stem
            data = read_scenario(scenario_dir, name)
            plot_scenario_data(data, scenario_dir_name, name)

    elif scenario_name == "success_rates":
        print_success_rates(scenario_dir)

    else:
        data = read_scenario(scenario_dir, scenario_name)
        plot_scenario_data(data, scenario_dir_name, scenario_name)

if __name__ == "__main__":
    main()