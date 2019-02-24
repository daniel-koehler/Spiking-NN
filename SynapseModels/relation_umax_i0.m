% model parameters

global T_M;     % time constant of IAF-neuron
global T_E;     % excitatory synaptic time constant
global T_I;     % inhibitory synaptic time constant

syms I_0 U_Peak

t_0E = log(T_E/T_M)*(T_E*T_M)/(T_E-T_M);
t_0I = log(T_I/T_M)*(T_I*T_M)/(T_I-T_M);

U_PeakE = I_0 .* (T_E*T_M)/(T_E-T_M) * (exp(-t_0E/T_E) - exp(-t_0E/T_M));
U_PeakI = -I_0 .* (T_I*T_M)/(T_I-T_M) * (exp(-t_0I/T_I) - exp(-t_0I/T_M));

I_0E = U_Peak/(exp(-t_0E/T_E) - exp(-t_0E/T_M)) * (T_E+T_M)/(T_E*T_M) 
I_0I = U_Peak/(exp(-t_0E/T_I) - exp(-t_0I/T_M)) * (T_I+T_M)/(T_I*T_M)

plot(i0, U_PeakE)
%hold on
%plot(i0, U_PeakI)