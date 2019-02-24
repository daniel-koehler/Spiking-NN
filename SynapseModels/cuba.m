function dY = vogels_abbott(t, Y)

% Model parameters:
global T_M;     % time constant of IAF-neuron
global T_E;     % excitatory synaptic time constant
global T_I;     % inhibitory synaptic time constant

global V_Rest;  % membrane rest potential

V_M = Y(1);
I_E = Y(2);
I_I = Y(3);

dY = zeros(3,1);

dY(1) = (V_Rest - V_M)/T_M + I_E - I_I;
dY(2) = - I_E / T_E;
dY(3) = - I_I / T_I;