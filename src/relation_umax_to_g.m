%% Simulation parameters:
t_curr = 0;
t_end = 50;
dt = 0.1;

%% Model parameters:
global T_M;     % time constant of IAF-neuron
global T_E;     % excitatory synaptic time constant
global T_I;     % inhibitory synaptic time constant

global E_E;     % excitatory reverse potential [mV]
global E_I;     % inhibitory reverse potential [mV]
global V_Rest;  % resting membrane potential

T_M = 20;       % [ms]
T_E = 5;        % [ms]
T_I = 10;       % [ms]

E_E = 0;        % [mV]
E_I = -80;      % [mV]
V_Rest = -60;   % [mV]
V_Theta = -50;  % spiking threshold voltage [mV]
V_Peak = 0.15;  % peak voltage for PSP, used to calculate current per synapse [mV]

T_Ref = 5;      % refractory period of the neuron [ms]

f_E = 10;       % avg. firing rate of excitatory synapse [Hz]
f_I = 10;       % avg. firing rate of inhibitory synapse [Hz]

% 4:1 ratio of excitatory to inhibitory neurons proposed by Vogels and Abbotts
n_E = 1000;      % number of excitatory synapses
n_I = 250;      % number of inhibitory synapses



%%
% Elapsed time since the neuron fired:
T_Ela = T_Ref;

V_max = [];
for g_0E = 0.0001:0.00001:0.001
    % initial condition
    Y = [-60 g_0E 0];
    step = 1;
    t_curr = 0;
    while t_curr < t_end
           [t,Y_T] = ode45(@coba, [0 dt], Y);       
           Y = Y_T(end,:);      % save only last element of Y_T

           Y_Res(step,:) = Y;

           if (Y(1) >= V_Theta) && (T_Ela >= T_Ref)
               Y(1) = V_Rest;
               T_Ela = 0;
           end
           T_Ela = T_Ela + dt;
           t_curr = t_curr + dt;
           step = step + 1;     
    end
    V_max(end+1) = max(Y_Res(:,1));
end

g_E = 0.0001:0.00001:0.001;    % time axis

%% Plotting:
figure('units','normalized','outerposition',[0 0 1 1])

linewidth = 1.5;
% membrane potential
plot(g_E, V_max, 'lineWidth', linewidth)
grid on
ylabel('V_max [mV]')
xlabel('g_E [mS]')
