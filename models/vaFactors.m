function factors = vaFactors(t)
% Calculate factors for exponential integration at time t

global tauL;    % time constant of IAF-neuron
global tauEx;   % exc. synaptic time constant
global tauIn;   % inh. synaptic time constant

% global EEx;     % exc. reverse potential
% global EIn;     % inh. reverse potential
% global EAvg;
% global RL;      % membrane resistance
% global IInj;

global const1;
global const2;
global const3;
global const4;

factors = zeros(size(t));

% precalculate factors for exponential integration
factors(:,1) = t;
factors(:,2) = exp(-tauEx * t);
factors(:,3) = exp(-tauIn * t);
factors(:,4) = exp(-tauL * t);
factors(:,5) = const1 * (factors(:,4) - factors(:,2));
factors(:,6) = const2 * (factors(:,4) - factors(:,3));
% constant injected current
factors(:,7) = exp(tauL * t)*const3 .* (const4 - factors(:,4));

% factors(:,5) = (EAvg - EEx) * RL * tauL / (tauL - tauEx) * (factors(4) - factors(2));
% factors(:,6) = (EAvg - EIn) * RL * tauL / (tauL - tauIn) * (factors(4) - factors(3));
% % constant injected current
% factors(:,7) = exp(tauL*t)*IInj*RL*((tauL^2 + tauEx*tauIn + tauEx*tauL + tauIn*tauL)/((tauEx + tauL)*(tauIn + tauEx)) - exp(-tauL*t));
end


