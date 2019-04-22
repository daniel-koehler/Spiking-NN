% Symbols
syms V_M(t)             % membrane voltage
syms g_E(t) g_I(t)      % conductances
%syms I_inj              % constant injected current
I_inj = 0;
syms V_Rest             % resting membrane potential
syms E_E E_I            % resting potentials
syms T_M T_E T_I        % INVERSE time constants
syms R_M                % membrane resistance
syms V_M0 g_E0 g_I0     % initial conditions

% Differential equations
ode1 = diff(V_M) == T_M * (V_M + R_M * (g_E * (E_E - V_Rest) + g_I * (E_I - V_Rest)));
ode2 = diff(g_E) == - g_E * T_E;
ode3 = diff(g_I) == - g_I * T_I;

odes = [ode1; ode2; ode3];
conds = [V_M(0) == V_M0; g_E(0) == g_E0; g_I(0) == g_I0];
S = dsolve(odes, conds);

dY(1) = S.V_M;
dY(2) = S.g_E;
dY(3) = S.g_I;

dY
