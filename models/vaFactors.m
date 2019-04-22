function factors = vaFactors(t)
% Calculate factors for exponential integration at time t

global tauL;    % time constant of IAF-neuron
global tauEx;   % exc. synaptic time constant
global tauIn;   % inh. synaptic time constant

global EEx;     % exc. reverse potential
global EIn;     % inh. reverse potential
global EAvg;
global RL;      % membrane resistance

factors = zeros(size(t));

% precalculate factors for exponential integration
factors(:,1) = t;
factors(:,2) = exp(-tauEx   * t);
factors(:,3) = exp(-tauIn   * t);
factors(:,4) = exp(-tauL    * t);
factors(:,5) = (EAvg - EEx) * RL * tauL / (tauL - tauEx) * (factors(4) - factors(2));
factors(:,6) = (EAvg - EIn) * RL * tauL / (tauL - tauIn) * (factors(4) - factors(3));

end