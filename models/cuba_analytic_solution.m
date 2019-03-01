% Symbols for description of the system of ODEs
syms V_M(t) I_E(t) I_I(t)   % state variables
syms T_M T_E T_I V_rest     % constants
syms V_0 I_0E I_0I          % initial values

ode1 = diff(V_M) == (V_rest - V_M)/T_M + I_E - I_I;
ode2 = diff(I_E) == - I_E / T_E;
ode3 = diff(I_I) == - I_I / T_I;

odes = [ode1; ode2; ode3];
conds = [V_M(0) == V_0; I_E(0) == I_0E; I_I(0) == I_0I];
S = dsolve(odes, conds);

dY(1) = S.V_M;
dY(2) = S.I_E;
dY(3) = S.I_I;

dY