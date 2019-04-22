% Analytic solution of the ODE system for current based synapses (CUBA).

function Y = vaAnalytic(Y0, factors)
% Inputs:
%   Y0:         n x 4 array containing initial conditions for [TEla, VM, gEx, gIn]
%   factors:    Factors for exponential integration
% Returns:
%   Y:          n x 4 array containing solution of the n ODE systems at time h

global tauRef
global EL

Y = zeros(size(Y0));

Y(:,1) = Y0(:,1) + factors(1);
Y(:,2) = factors(4) * Y0(:,2) + factors(5) * Y0(:,3) + factors(6) * Y0(:,4) + 11 * exp(-4);
% neurons in refractory period
Y((Y0(:,1) < tauRef), 2) = EL;        % clamp membrane voltage to resting potential
Y(:,3) = factors(2) * Y0(:,3);
Y(:,4) = factors(3) * Y0(:,4);