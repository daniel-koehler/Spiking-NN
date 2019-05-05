cuba_parameters

syms U_Peak I_0
t_0E = log(T_E/T_M)*(T_E*T_M)/(T_E-T_M);
t_0I = log(T_I/T_M)*(T_I*T_M)/(T_I-T_M);

U_PeakE(I_0) = I_0 * (T_E*T_M)/(T_E-T_M) * (exp(-t_0E/T_E) - exp(-t_0E/T_M));
U_PeakI(I_0) = -I_0 * (T_I*T_M)/(T_I-T_M) * (exp(-t_0I/T_I) - exp(-t_0I/T_M));

I_0E(U_Peak) = -U_Peak/(exp(-t_0E/T_E) - exp(-t_0E/T_M)) * (T_E+T_M)/(T_E*T_M); 
I_0I(U_Peak) = U_Peak/(exp(-t_0E/T_I) - exp(-t_0I/T_M)) * (T_I+T_M)/(T_I*T_M);

fplot(I_0E,[-0.5 0.5])
xlabel('EPSP [mV]')
ylabel('Synaptic current [mA]')