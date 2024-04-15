
using Random
using CSV
using DataFrames
using Distributions
using JSON

THIS_DIR = @__DIR__
TIME_SERIES_DIR = THIS_DIR * "/time_series"
CATEGORY_TO_FILE = Dict(
    "cloudy" => TIME_SERIES_DIR * "pv_cloudy_day_10kW.csv",
    "sunny" => TIME_SERIES_DIR * "pv_sunny_day_10kW.csv",
    "low" => TIME_SERIES_DIR * "wind_low_day.csv",
    "mid" => TIME_SERIES_DIR * "wind_mid_day.csv",
    "high" => TIME_SERIES_DIR * "wind_high_day.csv")

OUTDIR = THIS_DIR * "/scenarios"

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

function make_pv_gen(rng, pv_category)
    # normal noise on real time series
    # values use PV_COV value between each other
    raw_values = CSV.read(CATEGORY_TO_FILE[pv_category], DataFrame)
    values_vector = raw_values[!, :P_REL]
    dist_std = [PV_STD for _ in 1:length(values_vector)]
    rolled_values = zeros(Float64, length(values_vector))

    for i in eachindex(rolled_values)
        dist = Normal(values_vector[i], dist_std[i])
        rv = rand(rng, dist[i])
        if rv > PV_MAX
            rv = PV_MAX
        end
        if rv < 0
            rv = 0
        end

        rolled_values[i] = rv
    end

    return Dict("std" => dist_std, "rolled" => rolled_values)
end

function make_wind_gen(rng, wind_category)
    # normal noise on real time series
    # values use WIND_COV value between each other
    raw_values = CSV.read(CATEGORY_TO_FILE[wind_category], DataFrame)
    values_vector = raw_values[!, :P_REL]

    dist_std = [WIND_STD for _ in 1:length(values_vector)]
    rolled_values = zeros(Float64, length(values_vector))

    for i in eachindex(rolled_values)
        dist = Normal(values_vector[i], dist_std[i])
        rv = rand(rng, dist[i])
        if rv > WIND_MAX
            rv = WIND_MAX
        end
        if rv < 0
            rv = 0
        end

        rolled_values[i] = rv
    end

    return Dict("std" => dist_std, "rolled" => rolled_values)
end

function make_other_gen(rng)
    # normal noise
    # values use OTHER_COV value between each other 

end

function make_load(rng, n)
    # normal noise
    # values use LOAD_COV value between each other

end

function save_scenario(data, scenario_name)
    fname = OUTDIR * "/" * scenario_name * ".json"
    open(fname, "w") do f
        json_data = JSON.json(data)
        write(f, json_data)
    end
end

function make_scenario(pv_category, wind_category, rng, scenario_name)
    output = Dict{String, Any}()

    # given this random seed and the wind/pv category, generate:
    # 12 load datasets
    #   -> slightly varied by gaussian noise
    # fields: load
    for i in 1:N_LOAD
        load = make_load(rng, N_LOAD)
        f_name = "load_" * str(i)
        output[f_name] = load
    end

    # 4 PV curves
    for i in 1:N_PV
        pv_gen = make_pv_gen(rng, pv_category)
        f_name = "pv_" * str(i)
        output[f_name] = pv_gen
    end
    

    # 4 wind curves
    for i in 1:N_WIND
        wind_gen = make_wind_gen(rng, wind_category)
        f_name = "wind_" * str(i)
        output[f_name] = wind_gen
    end

    # 4 battery curves
    for i in 1:N_OTHER
        other_gen = make_other_gen(rng)
        f_name = "other_" * str(i)
        output[f_name] = other_gen
    end
    

    # save everything to csv
    save_scenario(output, scenario_name)
end


function main()
    seed, scenario_name = parse_args()

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
        make_scenario(pv, wind, rng, scenario_name)
    end
end


main()