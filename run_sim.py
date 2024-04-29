from src.grid_simulation.simulation import run_sim
import seaborn as sns


def main():
    # sequentially set grid values and calculate power flow
    # returns relative trafo load for each time step
    trafo_load_percents, sum_load, sum_gen1, sum_gen2, sum_gen3 = run_sim("test1")

if __name__ == "__main__":
    main()