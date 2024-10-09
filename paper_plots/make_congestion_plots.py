import seaborn as sns
import matplotlib.pyplot as plt
import csv
from collections import deque
from copy import deepcopy
import pandas as pd
import os

data = [ 0.35,
  0.34,
  0.33,
  0.32,
  0.31,
  0.30,
  0.29,
  0.28,
  0.27,
  0.24,
  0.22,
  0.2,
  0.2,
  0.2,
  0.2,
  0.2,
  0.22,
  0.24,
  0.25,
  0.26,
  0.28,
  0.29,
  0.30,
  0.31,
  0.36,
  0.41,
  0.45,
  0.50,
  0.53,
  0.58,
  0.6,
  0.6,
  0.62,
  0.65,
  0.66,
  0.68,
  0.7,
  0.71,
  0.72,
  0.73,
  0.74,
  0.75,
  0.76,
  0.77,
  0.78,
  0.79,
  0.8,
  0.8,
  0.79,
  0.72,
  0.7,
  0.68,
  0.66,
  0.62,
  0.6,
  0.58,
  0.55,
  0.54,
  0.52,
  0.5,
  0.49,
  0.51,
  0.6,
  0.68,
  0.7,
  0.75,
  0.78,
  0.8,
  0.82,
  0.84,
  0.86,
  0.88,
  0.9,
  0.91,
  0.92,
  0.9,
  0.9,
  0.87,
  0.84,
  0.81,
  0.78,
  0.75,
  0.72,
  0.69,
  0.66,
  0.63,
  0.60,
  0.57,
  0.54,
  0.51,
  0.48,
  0.45,
  0.42,
  0.39,
  0.36,
  0.35
]

extra_load = [0] * 96

extra_load[28] = 1.15 - data[28]
extra_load[29] = 1.15 - data[29]

extra_load[47] = 1.15 - data[47]
extra_load[48] = 1.15 - data[48]

extra_load[65] = 1.15 - data[65]
extra_load[66] = 1.15 - data[66]

extra_load[80] = 1.15 - data[80]
extra_load[81] = 1.15 - data[81]

total_load = [data[i] + extra_load[i] for i in range(96)]

plot_data = pd.DataFrame({
  "time": list(range(96)),
  "Household Loads": data,
  "induced": extra_load,
  "Node 13 Load": total_load
})


colors = ["lightblue", "red"]
# fig = sns.barplot(plot_data, x="time", y="total_load", hue="induced congestion")
# bar_2 = sns.barplot(plot_data, x="time", y="induced congestion")

w = 1

ax = plot_data.plot(x="time", y="Node 13 Load", kind="bar", color="orange", width=w)
plot_data.plot(x="time", y="Household Loads", kind="bar", ax=ax, color="blue", width=w)

ax.axhline(1.0, color='red', ls='dotted')
ax.set(xlabel="time [15 min]")
ax.set(ylabel="relative transformer load")

for ind, label in enumerate(ax.get_xticklabels()):
    if ind % 10 == 0:  # every 10th label is kept
        label.set_visible(True)
    else:
        label.set_visible(False)

dir_path = os.path.dirname(os.path.realpath(__file__))
fig_path = os.path.join(dir_path, "idealized_load.png")
plt.savefig(fig_path)

# ------------
plt.clf()

# time series plots for Wind, PV, and Battery curves.
bat_data = [0.8] * 96
pv_data = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.21, 0.29, 0.36, 0.43, 0.48, 0.53, 0.58, 0.62, 0.66, 0.7, 0.73, 0.76, 0.79, 0.81, 0.83, 0.85, 0.87, 0.89, 0.9, 0.91, 0.92, 0.92, 0.93, 0.93, 0.93, 0.93, 0.93, 0.92, 0.91, 0.9, 0.89, 0.87, 0.85, 0.83, 0.81, 0.79, 0.77, 0.73, 0.7, 0.66, 0.62, 0.58, 0.53, 0.48, 0.43, 0.36, 0.29, 0.21, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
wind_data = [0.04, 0.11, 0.17, 0.23, 0.29, 0.35, 0.4, 0.45, 0.5, 0.54, 0.58, 0.62, 0.65, 0.69, 0.72, 0.74, 0.77, 0.79, 0.81, 0.83, 0.84, 0.86, 0.87, 0.88, 0.89, 0.89, 0.9, 0.9, 0.9, 0.9, 0.9, 0.89, 0.89, 0.88, 0.88, 0.87, 0.86, 0.85, 0.83, 0.82, 0.81, 0.79, 0.78, 0.76, 0.75, 0.73, 0.7, 0.69, 0.67, 0.66, 0.64, 0.62, 0.6, 0.58, 0.56, 0.54, 0.52, 0.49, 0.47, 0.45, 0.43, 0.41, 0.39, 0.37, 0.35, 0.33, 0.32, 0.3, 0.28, 0.26, 0.24, 0.23, 0.21, 0.19, 0.18, 0.16, 0.15, 0.14, 0.12, 0.1, 0.1, 0.09, 0.08, 0.07, 0.06, 0.05, 0.04, 0.04, 0.03, 0.02, 0.02, 0.01, 0.01, 0.01, 0.0, 0.0]


# the actual plot
plot_data = pd.DataFrame({
  #"time": list(range(96)),
  "PV": pv_data,
  "Wind": wind_data,
  "battery": bat_data
})

fig = sns.lineplot(plot_data)

fig.set(xlabel="time [15 min]")
fig.set(ylabel="relative generation output")

# ax = plot_data.plot(x="time", kind="line")
# ax.set(xlabel="Time [15 min]")
# ax.set(ylabel="relative output capacity")

point = pd.DataFrame({'x': [28, 47, 65, 80], 'y': [0.95, 0.95, 0.95, 0.95]})
scatter = fig.scatter(point['x'], point['y'], marker='v', color='r', label='congestion')

handles, labels = plt.gca().get_legend_handles_labels()
plt.legend(handles=handles, loc="center left")

dir_path = os.path.dirname(os.path.realpath(__file__))
fig_path = os.path.join(dir_path, "generators.png")
plt.savefig(fig_path)