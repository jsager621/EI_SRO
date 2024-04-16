
using Random
using CSV
using DataFrames
using Distributions, Copulas
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
PV_STD = 0.2 # 20%

# wind
WIND_MAX = 10 * 1000 # 10 kw
WIND_STD = 0.3 # 30%

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
    # TODO
    return 0
end

function make_pv_gen!(rng, pv_category, n, output)
    # normal noise on real time series
    # values use PV_COV value between each other
    raw_values = CSV.read(CATEGORY_TO_FILE[pv_category], DataFrame)
    values_vector = raw_values[!, :P_REL]

    cov_matrix = zeros(Float64, n, n)
    for (i, j) in Iterators.product(1:n, 1:n)
        cov_matrix[i, j] = i == j ? 1.0 : PV_COV
    end

    copula = GaussianCopula(cov_matrix)

    # n distributions per time step
    rolled_values = Vector{Vector{Float64}}()

    for i in eachindex(values_vector)
        marginals = tuple([Normal(values_vector[i], PV_STD) for i in 1:n])
        dist = SklarDist(copula, marginals)
        rv = clamp!(rand(rng, dist, 1) * PV_MAX, 0, PV_MAX)
        push!(rolled_values, rv)
    end

    output["PV"] = Dict(
        "scale" => PV_MAX,
        "std" => PV_STD,
        "mean" => values_vector,
        "rolled" => rolled_values)
end

function make_wind_gen!(rng, wind_category, n, output)
    # normal noise on real time series
    # values use WIND_COV value between each other
    raw_values = CSV.read(CATEGORY_TO_FILE[wind_category], DataFrame)
    values_vector = raw_values[!, :P_REL]

    cov_matrix = zeros(Float64, n, n)
    for (i, j) in Iterators.product(1:n, 1:n)
        cov_matrix[i, j] = i == j ? 1.0 : WIND_COV
    end

    copula = GaussianCopula(cov_matrix)

    # n distributions per time step
    rolled_values = Vector{Vector{Float64}}()

    for i in eachindex(values_vector)
        marginals = tuple([Normal(values_vector[i], WIND_STD) for i in 1:n])
        dist = SklarDist(copula, marginals)
        rv = clamp!(rand(rng, dist, 1) * WIND_MAX, 0, WIND_MAX)
        push!(rolled_values, rv)
    end

    output["WIND"] = Dict(
        "scale" => PV_MAX,
        "std" => PV_STD,
        "mean" => values_vector,
        "rolled" => rolled_values)
end

function make_other_gen!(rng, n, output)
    # normal noise
    # values use OTHER_COV value between each other 
    cov_matrix = zeros(Float64, n, n)
    for (i, j) in Iterators.product(1:n, 1:n)
        cov_matrix[i, j] = i == j ? 1.0 : OTHER_COV
    end
    copula = GaussianCopula(cov_matrix)

    # consisten OTHER_MEAN +- OTHER_STD values 
    # 96 values, n times
    marginals = tuple([Normal(OTHER_MEAN, OTHER_STD) for i in 1:n])
    dist = SklarDist(copula, marginals)
    rolled_values = clamp!(rand(rng, dist, 96), 0, OTHER_MAX)

    output["OTHER"] = Dict(
        "min" => OTHER_MIN,
        "max" => OTHER_MAX,
        "mean" => OTHER_MEAN,
        "std" => OTHER_STD,
        "rolled" => rolled_values)
end

function make_load!(rng, n, output)
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
    output = Dict{String,Any}()

    # given this random seed and the wind/pv category, generate:
    # 12 load datasets
    make_load!(rng, N_LOAD, output)

    # 4 PV curves
    make_pv_gen!(rng, pv_category, N_PV, output)

    # 4 wind curves
    make_wind_gen!(rng, wind_category, N_WIND, output)

    # 4 battery curves
    make_other_gen!(rng, N_OTHER, output)

    # save everything to json
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