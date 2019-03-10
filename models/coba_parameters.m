% Parameters for conductance based synapse models

global T_M;     % time constant of IAF-neuron
global T_E;     % excitatory synaptic time constant
global T_I;     % inhibitory synaptic time constant

global E_E;     % excitatory reverse potential [mV]
global E_I;     % inhibitory reverse potential [mV]
global V_Rest;  % resting membrane potential

T_M = 20;       % [ms]
T_E = 5;        % [ms]
T_I = 10;       % [ms]

E_E = 0;        % [mV]
E_I = -80;      % [mV]
V_Rest = -60;   % [mV]
V_Theta = -50;  % spiking threshold voltage [mV]
V_Peak = 0.15;  % peak voltage for PSP, used to calculate current per synapse [mV]

T_Ref = 5;      % refractory period of the neuron [ms]

% Excitatory and inhibitory conductance values [mS]
dg_E = 0.0008;
dg_I = 0.0015;