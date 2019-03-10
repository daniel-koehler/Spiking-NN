% Symbols for description of the system of ODEs
syms V_M(t) g_E(t) g_I(t)   % state variables
syms T_M T_E T_I V_rest E_E E_I     % constants
syms V_0 g_0E g_0I          % initial values

ode1 = diff(V_M) == (V_Rest - V_M)/T_M + g_E * (E_E - V_M) + g_I * (E_I - V_M);
ode2 = diff(g_E) == - g_E / T_E;
ode3 = diff(g_I) == - g_I / T_I;

odes = [ode1; ode2; ode3];
conds = [V_M(0) == V_0; g_E(0) == g_0E; g_I(0) == g_0I];
S = dsolve(odes, conds);

dY(1) = S.V_M;
dY(2) = S.g_E;
dY(3) = S.g_I;

dY(1)