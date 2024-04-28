
from src.grid_simulation.grid import SimGrid
import json
import os

THIS_DIR = os.path.dirname(os.path.realpath(__file__))
SCENARIO_DIR = os.path.join(THIS_DIR, "../../scenarios")

def parse_scenario_dict(scenario_dict):
    # 96 * 12 values
    LOAD = "LOAD"
    NODE_13 = "NODE_13"

    # 96 * 4 values each
    OTHER = "OTHER"
    PV = "PV"
    WIND = "WIND"

    # parse everything to an output such that:
    # LOADS (1-13):
    #   node_id : [l1, l2, ..., l96]
    # Gens (1-12):
    #   node_id: [g1, g2, ..., g96]

def read_scenario(scenario_name):
    scenario_fname = os.path.join(SCENARIO_DIR, scenario_name, ".json")
    output = {}
    with open(scenario_fname, "r") as f:
        output = json.load(f)

    return parse_scenario_dict(output)

def run_sim(scenario_name):
    pass