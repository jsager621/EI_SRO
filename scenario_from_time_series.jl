
using Random
using CSV
using DataFrames
using JSON

THIS_DIR = @__DIR__
TIME_SERIES_DIR = THIS_DIR * "/time_series"
CATEGORY_TO_FILE = {
    "cloudy": TIME_SERIES_DIR * "pv_cloudy_day_10kW.csv",
    "sunny": TIME_SERIES_DIR * "pv_sunny_day_10kW.csv",
    "low": TIME_SERIES_DIR * "wind_low_day.csv",
    "mid": TIME_SERIES_DIR * "wind_mid_day.csv",
    "high": TIME_SERIES_DIR * "wind_high_day.csv"}

# defines possible ranges for output and distributions
# for the given category

# PV
PV_MAX = 10 * 1000 # 10 kw
PV_STD = 2 * 1000

# wind
WIND_MAX = 10 * 1000 # 10 kw
WIND_STD = 3 * 1000

# some kind of weather independent normally distributed generator
OTHER_MEAN = 5 * 1000 # 5kw
OTHER_STD = 2 * 1000 # 2kw
OTHER_MIN = 0
OTHER_MAX = 10 * 1000 # max 10kw


N_PV = N_WIND = N_OTHER = 4
N_LOAD = N_PV + N_WIND + N_OTHER

# NOTE: 
# Values of the same category are modeled with the covariances defined below.
# Values of different categories are modeled as independent.
# This is just a simplification for scenario generation.
# The problem instantiation itself can handle arbitrary covariance matrices and
# the model will later be extended to use non-gaussia copulas as well.
PV_COV = 0.7
WIND_COV = 0.4
OTHER_COV = 0.1
LOAD_COV = 0.2


function parse_args()
    return 0
end

function make_pv_gen(rng, pv_category, n)
    # normal noise on real time series
    # values use PV_COV value between each other
    raw_values = CSV.read(CATEGORY_TO_FILE[pv_category], DataFrame)
    values_vector = raw_values[!, :P_REL]

end

function make_wind_gen(rng, wind_category, n)
    # normal noise on real time series
    # values use WIND_COV value between each other
    raw_values = CSV.read(CATEGORY_TO_FILE[wind_category], DataFrame)

end

function make_other_gen(rng, n)
    # normal noise
    # values use OTHER_COV value between each other 

end

function make_load(rng, n)
    # normal noise
    # values use LOAD_COV value between each other

end

function merge_data(time_series)

end

function save_scenario(data)

end

function make_scenario(pv_category, wind_category, rng)
    # given this random seed and the wind/pv category, generate:
    # 12 load datasets
    #   -> slightly varied by gaussian noise
    # fields: load
    load = make_load(rng, N_LOAD)

    # 4 PV curves
    # - beta, slight variation in parameters
    # - and their instantiated rolled values
    # fields: alpha, beta, scale, p_rolled
    pv_gen = make_pv_gen(rng, pv_category, N_PV)

    # 4 wind curves
    # - weibull, slight variation in parameters
    # - and their instantiated rolled values
    # fields: lambda, k, scale, p_rolled
    wind_gen = make_wind_gen(rng, wind_category, N_WIND)

    # 4 battery curves
    # - gaussian, between min/max state of charge
    # - and their instantiated rolled values
    # fields: mean, std, min, max, p_rolled
    other_gen = make_other_gen(rng, N_BAT)

    # save everything to csv
    data = merge_data([load, pv_gen, wind_gen, other_gen])
    save_scenario(data)
end


function main()
    seed = parse_args()

    categories = [
        ("cloudy", "low"),
        ("cloudy", "mid"),
        ("cloudy", "high"),
        ("sunny", "low"),
        ("sunny", "mid"),
        ("sunny", "high"),
    ]

    for (pv, wind) in categories
        rng = Xoshiro(seed)
        make_scenario(pv, wind, rng)
    end
end


main()