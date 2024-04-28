from src.grid_simulation.simulation import run_sim


def main():
    # read scenario files

    # sequentially set grid values and calculate power flow
    # save relevant trafo load
    # save trafo load as outputs (json, scenario file name field + output time series)
    run_sim("test1")
    pass

if __name__ == "__main__":
    main()