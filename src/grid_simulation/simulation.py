
from src.grid_simulation.grid import SimGrid
import json
import os

THIS_DIR = os.path.dirname(os.path.realpath(__file__))
SCENARIO_DIR = os.path.join(THIS_DIR, "../../scenarios")

# 96 * 12 values
LOAD = "LOAD"
ROLLED_VALUES = "rolled"
NODE_13 = "NODE_13"

# 96 * 4 values each
OTHER = "OTHER"
PV = "PV"
WIND = "WIND"

def parse_scenario_dict(scenario_dict):
    load_13_values = []
    if NODE_13 in scenario_dict.keys():
        load_13_values = scenario_dict[NODE_13]
    else:
        load_13_values = [0.0] * 96

    load_values = [[] for i in range(13)]
    for values in scenario_dict[LOAD][ROLLED_VALUES]:
        for i in range(12):
            load_values[i].append(values[i])

    load_values[12] = load_13_values

    gen_values = [[] for i in range(13)]
    gen_values[12] = [0.0] * 96 # node 13 gen is always 0

    for values in scenario_dict[OTHER][ROLLED_VALUES]:
        for i in range(4):
            gen_values[i].append(values[i])

    for values in scenario_dict[PV][ROLLED_VALUES]:
        for i in range(4):
            gen_values[i+4].append(values[i])

    for values in scenario_dict[WIND][ROLLED_VALUES]:
        for i in range(4):
            gen_values[i+8].append(values[i])

    return (load_values, gen_values)

def read_scenario(scenario_name):
    scenario_fname = os.path.join(SCENARIO_DIR, scenario_name + ".json")
    output = {}
    with open(scenario_fname, "r") as f:
        output = json.load(f)

    return parse_scenario_dict(output)

def run_sim(scenario_name, selected_gens=[]):
    load_values, gen_values = read_scenario(scenario_name)

    grid = SimGrid()

    trafo_load_percents = []
    sum_load = []
    sum_gen1 = []
    sum_gen2 = []
    sum_gen3 = []

    for t in range(96):
        loads = [x[t] for x in load_values]
        gens = [x[t] if i in selected_gens else 0 for i, x in enumerate(gen_values)]

        grid.set_prosumer_loads_w(loads, gens)
        grid.run_powerflow()
        trafo_load_percents.append(grid.grid.res_trafo.loading_percent[0])
        sum_load.append(sum(loads))
        sum_gen1.append(sum(gens[0:4]))
        sum_gen2.append(sum(gens[4:8]))
        sum_gen3.append(sum(gens[8:12]))

    return trafo_load_percents, sum_load, sum_gen1, sum_gen2, sum_gen3
