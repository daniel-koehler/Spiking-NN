% Parameters for current based synapse models

global T_M;     % time constant of IAF-neuron
global T_E;     % exc. synaptic time constant
global T_I;     % inh. synaptic time constant

global V_Rest;  % resting membrane potential
global E_E;     % exc. reverse potential
global E_I;     % inh. reverse potential
global R_M;     % membrane resistance
global I_inj;   % constant injected depolarising current

T_M = 20;       % [ms]
T_E = 5;        % [ms]
T_I = 10;       % [ms]
V_Rest = -60;   % [mV]
E_E = 0;        % [mV]
E_I = -80;      % [mV]
R_M = 0.1;      % [GOhm]
I_inj = 110;    % [pA|
%I_inj = 0;    % [pA|
dg_E = 0.27;    % exc. synaptic strength [nS]
dg_I = 4.5;     % inh. synaptic strength [nS]
dg_Stim = 5;
V_Theta = -50;  % spiking threshold voltage [mV]
T_Ref = 5;      % refractory period of the neuron [ms]