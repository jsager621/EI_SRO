
CATEGORY_TO_FILE = {}
CATEGORY_TO_PARAMS_PV = {}
CATEGORY_TO_PARAMS_WIND = {}
N_PV = N_WIND = N_BAT = 4
N_LOAD = N_PV + N_WIND + N_BAT


function parse_args()

end

function make_pv_curves(pv_category, n)

end

function make_wind_curves(wind_category, n)

end

function make_battery_curves(n)

end

function make_load_curves(n)

end

function merge_data(time_series)

end

function save_scenario(data)

end


function main()
    pv_category, wind_category = parse_args()

    # given this random seed and the wind/pv category, generate:
    # 12 load datasets
    #   -> slightly varied by gaussian noise
    # fields: load
    load_curves = make_load_curves(N_LOAD)

    # 4 PV curves
    # - beta, slight variation in parameters
    # - and their instantiated rolled values
    # fields: alpha, beta, scale, p_rolled
    pv_curves = make_pv_curves(pv_category, N_PV)

    # 4 wind curves
    # - weibull, slight variation in parameters
    # - and their instantiated rolled values
    # fields: lambda, k, scale, p_rolled
    wind_curves = make_wind_curves(wind_category, N_WIND)

    # 4 battery curves
    # - gaussian, between min/max state of charge
    # - and their instantiated rolled values
    # fields: mean, std, min, max, p_rolled
    battery_curves = make_battery_curves(N_BAT)

    # save everything to csv
    data = merge_data([load_curves, pv_curves, wind_curves, battery_curves])
    save_scenario(data)
end


main()