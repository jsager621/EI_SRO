
from grid import SimGrid
import json
import os

THIS_DIR = os.path.dirname(os.path.realpath(__file__))
SCENARIO_DIR = os.path.join(THIS_DIR, "../../scenarios")

def parse_scenario_dict(scenario_dict):
    # 96 * 12 values
    LOAD = "LOAD"
    ROLLED_VALUES = "rolled"
    NODE_13 = "NODE_13"
    

    node_13_values = []
    if NODE_13 in scenario_dict.keys():
        node_13_values = scenario_dict[NODE_13]
    else:
        node_13_values = [0.0] * 96

    node_values = [[]] * 13
    for values in scenario_dict[LOAD][ROLLED_VALUES]:
        for i in range(12):
            node_values[i].append(values[i])

    node_values[12] = node_13_values


    # 96 * 4 values each
    OTHER = "OTHER"
    PV = "PV"
    WIND = "WIND"

    gen_values = [[]] * 13
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

    return (node_values, gen_values)

def read_scenario(scenario_name):
    scenario_fname = os.path.join(SCENARIO_DIR, scenario_name + ".json")
    output = {}
    with open(scenario_fname, "r") as f:
        output = json.load(f)

    return parse_scenario_dict(output)

def run_sim(scenario_name):
    pass
