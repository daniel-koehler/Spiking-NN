% Parameters for current based synapse models

global tauL;    % time constant of IAF-neuron
global tauEx;   % exc. synaptic time constant
global tauIn;   % inh. synaptic time constant
global tauRef;  % refractory period

%global VRest;   % resting membrane potential
global EL;      % leak reverse potential
global EEx;     % exc. reverse potential
global EIn;     % inh. reverse potential
global EAvg;
global RL;      % membrane resistance


tauL = 1/20;    % [ms^-1]
tauEx = 1/5;    % [ms^-1]
tauIn = 1/10;   % [ms^-1]
tauRef = 5;     % [ms]
%VRest = -60;    % [mV]
EL = 0;         % [mV]
EAvg = -60;
EEx = 0;        % [mV]
EIn = -80;      % [mV]
RL = 0.1;       % [GOhm]

dgEx = 0.27;    % change in exc. synaptic conductance [nS]
dgIn = 4.5;     % change in inh. synaptic conductance [nS]

wEx = dgEx;
wIn = -dgIn;

VTheta = 10;   % spiking threshold voltage [mV]
