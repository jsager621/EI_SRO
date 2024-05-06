import json
import seaborn as sns
import os
import sys
from pathlib import Path

this_dir = os.path.dirname(os.path.realpath(__file__))
scenario_dir = os.path.join(this_dir, "outputs", "logs")
plot_dir = os.path.join(this_dir, "outputs", "plots")

def read_scenario(scenario_name):
    fname = os.path.join(scenario_dir, scenario_name + ".json", )

    with open(fname, "r") as f:
        data = json.load(f)
        return data

def plot_scenario_data(data, scenario_name):
    out_fname = os.path.join(plot_dir, scenario_name + ".png")

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

    # seaborn.boxplot({"one": data, "two": data, "three": data}).set(xlabel="algo", ylabel="cost")
    plot = sns.boxplot(filtered_costs)
    plot.set(xlabel="algorithm", ylabel="cumulative result costs")
    plot.set(title=scenario_name[:-2])
    fig = plot.get_figure()
    fig.savefig(out_fname)
    fig.clf()


def print_success_rates():
    files = os.listdir(scenario_dir)
    scenarios = []
    for f in files:
        if "runtime" in f:
            continue
        name = Path(f).stem
        data = read_scenario(name)
        scenarios.append(data)

    algo_counters = {
        "bpso_approx": 0,
        "full_approx": 0
    }

    for scenario in scenarios:
        for i_problem in scenario.keys():
            bpso_data = scenario[i_problem]["bpso_approx"]
            full_data = scenario[i_problem]["full_approx"]
            # oracle_data = scenario[i_problem]["oracle"]

            bpso_successes = len([x for x in bpso_data[1] if x == 0])
            full_successes = len([x for x in full_data[1] if x == 0])

            algo_counters["bpso_approx"] += bpso_successes
            algo_counters["full_approx"] += full_successes

    print(algo_counters)
    print("bpso_approx: ", algo_counters["bpso_approx"] / 80000)
    print("full_approx: ", algo_counters["full_approx"] / 80000)

def main():
    if len(sys.argv) < 2:
        print("Please specify scenario name as command line arg.")
        return

    scenario_name = sys.argv[1]
    if scenario_name == "all":
        files = os.listdir(scenario_dir)
        for f in files:
            if "runtime" in f:
                continue
            name = Path(f).stem
            data = read_scenario(name)
            plot_scenario_data(data, name)

    elif scenario_name == "print":
        print_success_rates()

    else:
        data = read_scenario(scenario_name)
        plot_scenario_data(data, scenario_name)

if __name__ == "__main__":
    main()