
using Random

CATEGORY_TO_FILE = {
    "cloudy": "pv_cloudy_day_10kW.csv",
    "sunny": "pv_sunny_day_10kW.csv",
    "low": "wind_low_day.csv",
    "mid": "wind_mid_day.csv",
    "high": "wind_high_day.csv"}

# defines possible ranges for output and distributions
# for the given category
CATEGORY_TO_PARAMS_PV = {}
CATEGORY_TO_PARAMS_WIND = {}

N_PV = N_WIND = N_BAT = 4
N_LOAD = N_PV + N_WIND + N_BAT


function parse_args()
    return 0
end

function make_pv_curves(rng, pv_category, n)

end

function make_wind_curves(rng, wind_category, n)

end

function make_battery_curves(rng, n)

end

function make_load_curves(rng, n)

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
    load_curves = make_load_curves(rng, N_LOAD)

    # 4 PV curves
    # - beta, slight variation in parameters
    # - and their instantiated rolled values
    # fields: alpha, beta, scale, p_rolled
    pv_curves = make_pv_curves(rng, pv_category, N_PV)

    # 4 wind curves
    # - weibull, slight variation in parameters
    # - and their instantiated rolled values
    # fields: lambda, k, scale, p_rolled
    wind_curves = make_wind_curves(rng, wind_category, N_WIND)

    # 4 battery curves
    # - gaussian, between min/max state of charge
    # - and their instantiated rolled values
    # fields: mean, std, min, max, p_rolled
    battery_curves = make_battery_curves(rng, N_BAT)

    # save everything to csv
    data = merge_data([load_curves, pv_curves, wind_curves, battery_curves])
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