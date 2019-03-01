function dY = coba(t, Y)

% Model parameters:
global T_M;     % time constant of IAF-neuron
global T_E;     % excitatory synaptic time constant
global T_I;     % inhibitory synaptic time constant

global E_E;     % excitatory reverse potential [mV]
global E_I;     % inhibitory reverse potential [mV]
global V_Rest;  % membrane rest potential

V_M = Y(1);
g_E = Y(2);
g_I = Y(3);

dY = zeros(3,1);

dY(1) = (V_Rest - V_M)/T_M + g_E * (E_E - V_M) + g_I * (E_I - V_M);
dY(2) = - g_E / T_E;
dY(3) = - g_I / T_I;