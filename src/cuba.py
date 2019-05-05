from scipy.integrate import solve_ivp
from matplotlib import pyplot as plt
import numpy as np


# model parameters
V_rest = -60    #[mV]
T_M = 20        #[ms]
T_E = 5         #[ms]
T_I = 10        #[ms]

# simulation parameters
dt = 0.1        #[ms]
t_start = 0     #[ms]
t_end = 60      #[ms]


def cuba(t, y):
    global V_rest
    global T_M
    global T_E
    global T_I

    dy = np.zeros(3)

    dy[0] = (V_rest - y[0])/T_M + y[1] - y[2]
    dy[1] = -y[1]/T_E
    dy[2] = -y[2]/T_I

    return dy

# initial value 
y = [V_rest, 0 , 0]
y_plot = np.array([y]).T
t = np.arange(t_start, t_end, dt)

# timings of spikes
t_spikes_E = [2.3, 5]
t_spikes_I = []

for t_curr in t[:-1]:
    if t_curr in t_spikes_E:
        y[1] += 1
        print("Jup")
    if t_curr in t_spikes_I:
        y[2] += 1
        
    sol = solve_ivp(cuba, (0, dt), y, t_eval=[dt])
    y = sol.y[:,0]
    y_plot = np.append(y_plot, sol.y, axis=1)

plt.plot(t, y_plot[0])
plt.show()

