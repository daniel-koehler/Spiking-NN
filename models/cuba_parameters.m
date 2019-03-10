% Parameters for current based synapse models

global T_M;     % time constant of IAF-neuron
global T_E;     % excitatory synaptic time constant
global T_I;     % inhibitory synaptic time constant

global V_Rest;  % resting membrane potential

T_M = 20;       % [ms]
T_E = 5;        % [ms]
T_I = 10;       % [ms]

V_Rest = -60;   % [mV]
V_Theta = -50;  % spiking threshold voltage [mV]

EPSP = 0.15;      % peak voltage of EPSP [mV]
IPSP = 2.25;    % peak voltage of IPSP [mv]

T_Ref = 5;      % refractory period of the neuron [ms]

%%
% Calculate peak values for inhibitory and excitatory synaptic current
t_0E = log(T_E/T_M)*(T_E*T_M)/(T_E-T_M);    
t_0I = log(T_I/T_M)*(T_I*T_M)/(T_I-T_M);
i_0E = EPSP/(exp(-t_0E/T_E) - exp(-t_0E/T_M)) * (T_E-T_M)/(T_E*T_M);
i_0I = IPSP/(exp(-t_0I/T_I) - exp(-t_0I/T_M)) * (T_I-T_M)/(T_I*T_M);
