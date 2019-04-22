% Analytic solution of the ODE system for current based synapses (CUBA).

function Y = vogels_analytic(t, Y_0)
% Inputs:
%   - t:    time in ms
%   - Y_0:  n x 3 array containing n rows of [V_M, I_E, I_I]
% Return:
%   - Y:    n x 3 array containing solution of the n ODE systems at time t

% Model parameters:
global T_M;     % time constant of IAF-neuron
global T_E;     % exc. synaptic time constant
global T_I;     % inh. synaptic time constant
global V_Rest;  % membrane rest potential
global E_E;     % exc. reverse potential 
global E_I;     % inh. reverse potential
global R_M;     % membrane resistance
global I_inj    % constant injected current

Y = zeros(size(Y_0));

% with I_inj
Y(:,1) = exp(-t/T_M)*(exp(t/T_M)*(V_Rest + I_inj*R_M) + (T_M^2*Y_0(:,1) - T_M^2*V_Rest + T_E*T_I*Y_0(:,1) - T_E*T_M*Y_0(:,1) - T_E*T_I*V_Rest - T_I*T_M*Y_0(:,1) + T_E*T_M*V_Rest + T_I*T_M*V_Rest - I_inj*R_M*T_M^2 - I_inj*R_M*T_E*T_I + I_inj*R_M*T_E*T_M + I_inj*R_M*T_I*T_M - E_E*R_M*T_E*T_I*Y_0(:,2) + E_E*R_M*T_E*T_M*Y_0(:,2) - E_I*R_M*T_E*T_I*Y_0(:,3) + E_I*R_M*T_I*T_M*Y_0(:,3) + R_M*T_E*T_I*V_Rest*Y_0(:,2) + R_M*T_E*T_I*V_Rest*Y_0(:,3) - R_M*T_E*T_M*V_Rest*Y_0(:,2) - R_M*T_I*T_M*V_Rest*Y_0(:,3))/((T_E - T_M)*(T_I - T_M))) - (T_E*Y_0(:,2)*exp(-t/T_E)*(R_M*V_Rest - E_E*R_M))/(T_E - T_M) - (T_I*Y_0(:,3)*exp(-t/T_I)*(R_M*V_Rest - E_I*R_M))/(T_I - T_M);
Y(:,2) = Y_0(:,2)*exp(-t/T_E);
Y(:,3) = Y_0(:,3)*exp(-t/T_I);