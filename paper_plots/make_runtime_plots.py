import seaborn as sns
import matplotlib.pyplot as plt
import csv
from collections import deque
from copy import deepcopy
import pandas as pd
import json
import os

dir_path = os.path.dirname(os.path.realpath(__file__))
datafile = os.path.join(dir_path, "..", "outputs/logs/runtime_benchmark.json")

with open(datafile) as f:
    data = json.load(f)

ax = sns.lineplot(data)
ax.set(yscale="log")
ax.set(xlabel="Number of Resources", ylabel="Execution Time [ns]")



fig_path = os.path.join(dir_path, "time_data.png")
plt.savefig(fig_path)