import pandapower as pp
import pandapower.networks as ppnet
import numpy as np

# 12 households
# 1 problem inducer node (13)
# give access methods to set node values
# give access method to run powerflow
# positive value -> load
# negative value -> generation

# trafo: 160 kVA

class SimGrid():
    def __init__(self):

        self.grid = ppnet.create_kerber_landnetz_freileitung_1()
        for idx_l in range(len(self.grid.load)):
            self.grid.load.at[idx_l, "p_mw"] = 0
            self.grid.load.at[idx_l, "q_mvar"] = 0  # reactive power value

        self.load_bus_names = [x for x in self.grid.bus["name"] if x.startswith("bus")]

    def store_grid_results(self):
        self.grid_results_bus = {}
        self.grid_results_line = {}
        if not self.grid.res_bus.empty:  # powerflow converged
            for i_bus in range(len(self.grid.bus)):
                self.grid_results_bus[self.grid.bus.loc[i_bus, "name"]] = np.round(
                    self.grid.res_bus.loc[i_bus, "vm_pu"], 5
                )
            for i_line in range(len(self.grid.line)):
                self.grid_results_line[self.grid.line.loc[i_line, "name"]] = np.round(
                    self.grid.res_line.loc[i_line, "loading_percent"], 2
                )
            for i_trafo in range(len(self.grid.trafo)):
                self.grid_results_line[self.grid.trafo.loc[i_trafo, "name"]] = np.round(
                    self.grid.res_trafo.loc[i_trafo, "loading_percent"], 2
                )

    def set_prosumer_loads_kw(self, loads):
        n_real_loads = len(self.grid.load) - 1
        assert len(loads) == n_real_loads
        for i in range(n_real_loads):
            grid.grid.load.at[i, "p_mw"] = loads[i] / 1e3

    def set_dummy_load_kw(self, load):
        grid.grid.load.at[len(self.grid.load)-1, "p_mw"] = load / 1e3




if __name__ == "__main__":
    grid = SimGrid()

    grid.set_dummy_load_kw(50)
    grid.set_prosumer_loads_kw([10] * 12)
    # for idx_l in range(len(self.grid.load)):
    #     self.grid.load.at[idx_l, "p_mw"] = 0

    pp.runpp(
            grid.grid,
            numba=False,
            calculate_voltage_angles=False,
        )
    grid.store_grid_results()
    print(grid.grid.res_bus)
    print(grid.grid.res_line)
    print(grid.grid.res_trafo)