# %%
from copulas.univariate import GaussianUnivariate, BetaUnivariate, GammaUnivariate
import seaborn as sns
from scipy.stats import norm
import numpy as np

a = GaussianUnivariate()
a._params = {}
a.fitted = True
a._params["loc"] = 10.0
a._params["scale"] = 1


# What I want:
# define 2 marginals
# give their covariance
# make the corresponding copula
# plot the resulting distribution
x = a.sample(10000)
ax = sns.histplot(x, kde=False, stat='density', label='samples')

mu, std = norm.fit(x)

print(mu)
print(std)
# %%
