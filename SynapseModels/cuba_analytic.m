function Y = cuba_analytic(t, Y_0)
% Y_0: initial condition

% Model parameters:
global T_M;     % time constant of IAF-neuron
global T_E;     % excitatory synaptic time constant
global T_I;     % inhibitory synaptic time constant

global V_Rest;  % membrane rest potential

% solution obtained by vogels_abbott_solution.m
Y(1) = exp(-t/T_M)*(V_Rest*exp(t/T_M) + (T_M^2*Y_0(1) - T_M^2*V_Rest + T_E*T_I*Y_0(1) - T_E*T_M*Y_0(1) - T_I*T_M*Y_0(1) - T_E*T_I*V_Rest + T_E*T_M*V_Rest + T_I*T_M*V_Rest + Y_0(2)*T_E*T_M^2 - Y_0(3)*T_I*T_M^2 - Y_0(2)*T_E*T_I*T_M + Y_0(3)*T_E*T_I*T_M)/((T_E - T_M)*(T_I - T_M))) + (Y_0(2)*T_E*T_M*exp(-t/T_E))/(T_E - T_M) - (Y_0(3)*T_I*T_M*exp(-t/T_I))/(T_I - T_M);
Y(2) = Y_0(2)*exp(-t/T_E);
Y(3) = Y_0(3)*exp(-t/T_I);