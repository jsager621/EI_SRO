

function main()
    # read scenario files
    # for lines with a power value on node 13:
    #   - read size of the congestion (target value)
    #   - set target probability
    #   - read distributions of devices
    #   - make full covariance matrix
    #   - make marginals and resources
    #       - NOTE: remember scale factor (PV/WIND_MAX)
    #       - NOTE: set costs
    #   - make problem: 
    #       - NOTE: COMES PRE-INSTANTIATED!
    #   - pass problem to solvers
    #   - save solver results to same json file
end



main()