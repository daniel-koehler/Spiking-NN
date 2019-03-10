% Parameters for current based synapse models

global T_M;     % time constant of IAF-neuron
global T_E;     % exc. synaptic time constant
global T_I;     % inh. synaptic time constant

global V_Rest;  % resting membrane potential
global E_E;
global E_I;

T_M = 20;       % [ms]
T_E = 5;        % [ms]
T_I = 10;       % [ms]
V_Rest = -60;   % [mV]
E_E = 0;        % [mV]
E_I = -80;      % [mV]

dg_E = 0.0165;     % [µS]
dg_I = 0.225;      % [µS]
V_Theta = -50;  % spiking threshold voltage [mV]

T_Ref = 5;      % refractory period of the neuron [ms]
