using Copulas, Distributions, Random


function main()
    X₁ = Gamma(2,3)
    X₂ = Pareto()
    X₃ = LogNormal(0,1)
    C = ClaytonCopula(3,0.7) # A 3-variate Clayton Copula with θ = 0.7
    D = SklarDist(C,(X₁,X₂,X₃)) # The final distribution

    # This generates a (3,1000)-sized dataset from the multivariate distribution D
    simu = rand(D,1000)

    # While the following estimates the parameters of the model from a dataset: 
    D̂ = fit(SklarDist{FrankCopula,Tuple{Gamma,Normal,LogNormal}}, simu)
end



main()