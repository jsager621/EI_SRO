import json
import seaborn as sns
import os
import sys

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
    result_n_remaining = {}

    # find algo names
    first = data["1"]
    for algo_name in first.keys():
        result_costs[algo_name] = []
        result_v_remaining[algo_name] = []

    for algo_name in result_costs.keys():
        for problem_i in data.keys():
            result_costs[algo_name] += data[problem_i][algo_name][0]
            result_v_remaining[algo_name] += data[problem_i][algo_name][2]

    # for k in result_n_remaining.keys():
    #     print(k)
    #     print(result_n_remaining[k])


    # only add to the cost dataset if everyone got a valid solution
    # otherwise we get misleading total costs!
    fitlered_costs = {}
    for algo_name in result_costs.keys():
        fitlered_costs[algo_name] = [
            result_costs[algo_name][i] for i in range(len(result_costs[algo_name])) 
            if all([result_v_remaining[a][i] == 0 for a in result_costs.keys()])
            ]

    # seaborn.boxplot({"one": data, "two": data, "three": data}).set(xlabel="algo", ylabel="cost")
    plot = sns.boxplot(result_costs)
    plot.set(xlabel="algorithm", ylabel="result cost")
    fig = plot.get_figure()
    fig.savefig(out_fname)



def main():
    if len(sys.argv) < 2:
        print("Please specify scenario name as command line arg.")
        return

    scenario_name = sys.argv[1]
    data = read_scenario(scenario_name)
    plot_scenario_data(data, scenario_name)

if __name__ == "__main__":
    main()