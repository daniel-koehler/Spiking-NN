% Parameters for current based synapse models

global tauL;    % time constant of IAF-neuron
global tauEx;   % exc. synaptic time constant
global tauIn;   % inh. synaptic time constant
global tauRef;  % refractory period

%global VRest;   % resting membrane potential
global EL;      % leak reverse potential
global EEx;     % exc. reverse potential
global EIn;     % inh. reverse potential
global EAvg;    % resting potential
global RL;      % membrane resistance
global IInj;    % constant injected current

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
IInj = 110;     % [pA]

dgEx = 0.27;    % change in exc. synaptic conductance [nS]
dgIn = 4.5;     % change in inh. synaptic conductance [nS]

wEx = dgEx;
wIn = -dgIn;
wStim = 5;

VTheta = 10;   % spiking threshold voltage [mV]

% constants for integration used in vaFactors
global const1;
global const2;
global const3;
global const4;
const1 = (EAvg - EEx) * RL * tauL / (tauL - tauEx);
const2 = (EAvg - EIn) * RL * tauL / (tauL - tauIn);
const3 = IInj*RL;
const4 = (tauL^2 + tauEx*tauIn + tauEx*tauL + tauIn*tauL)/((tauEx + tauL)*(tauIn + tauL));

