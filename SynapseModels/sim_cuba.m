%% Simulation of single neuron with CUBA synapses

%% Simulation parameters:
clear;
dt = 0.1;       % simulation interval [ms]
t_curr = 0;    
t_start = 0;
t_end = 60;     % duration of simulation [ms]

%%
% Select input mode
% 0: Single spikes,
% 1: Poisson-distributed
% 2: Gamma-distributed
INPUT_MODE = 0;

%% 
% Select solver
% 0: Analytic solution,
% 1: ode45 (Runge-Kutta 4-5),
% 2: ode113 (Adams-Bashforth-Moulton)
SOLVER = 0;     % solver:

%% Model parameters:
global T_M;     % time constant of IAF-neuron
global T_E;     % excitatory synaptic time constant
global T_I;     % inhibitory synaptic time constant

global V_Rest;  % resting membrane potential

T_M = 20;       % [ms]
T_E = 5;        % [ms]
T_I = 10;       % [ms]

V_Rest = -60;   % [mV]
V_Theta = -50;  % spiking threshold voltage [mV]
V_Peak = 0.15;  % peak voltage for PSP [mV] (used to calculate current per synapse)

T_Ref = 5;      % refractory period of the neuron [ms]

f_E = 10;       % avg. firing rate of excitatory synapse [Hz]
f_I = 10;       % avg. firing rate of inhibitory synapse [Hz]

% 4:1 ratio of excitatory to inhibitory neurons proposed by Vogels and Abbotts
n_E = 1000;     % number of excitatory synapses
n_I = 250;      % number of inhibitory synapses

%%
% Calculate peak values for inhibitory and excitatory synaptic current
t_0E = log(T_E/T_M)*(T_E*T_M)/(T_E-T_M);    
t_0I = log(T_I/T_M)*(T_I*T_M)/(T_I-T_M);
i_0E = V_Peak/(exp(-t_0E/T_E) - exp(-t_0E/T_M)) * (T_E-T_M)/(T_E*T_M);
i_0I = V_Peak/(exp(-t_0I/T_I) - exp(-t_0I/T_M)) * (T_I-T_M)/(T_I*T_M);

%%
% INPUT_MODE = 0 - Use single spikes timed at:
t_spikes_E = [0.3, 10];    % timings for excitatory spikes (multiples of dt)
t_spikes_I = [40];    % timings for inhibitory spikes (multiples of dt)

%%
% INPUT_MODE = 1 - Use Poisson-distributed number of EPSPs and IPSPs. Where:
% $\lambda = \frac{f}{1000 ms} \cdot dt \cdot n$
% is the expected number of spikes per simulation time step $dt$.
lambda_E = f_E / 1000 * dt * n_E;
lambda_I = f_I / 1000 * dt * n_I;

%%
% Initial condition: $U_M = -60mV, I_E = 0nA, I_I = 0nA$
Y = [-60 0 0];

%%
% Variables for plotting:
spikes_E = zeros(1, t_end/dt);  % number of excitatory spikes at t
spikes_I = zeros(1, t_end/dt);  % number of inhibitory spikes at t
T_Res = t_start:dt:t_end-dt;    % time axis
Y_Res = Y;                      % V_M(t), I_E(t), I_I(t)                   

%%
% Elapsed time since the neuron fired:
T_Ela = T_Ref;

%% Simulation loop:
step = 1;
while t_curr < t_end
   % generate synaptic input
   switch INPUT_MODE
       case 0   % Single spikes           
           if ismembertol(t_curr, t_spikes_E, 0.001)
               Y(2) = Y(2) + i_0E;
               spikes_E(step) = 1;
           end
           if ismembertol(t_curr, t_spikes_I, 0.001)
               Y(3) = Y(3) + i_0I;
               spikes_I(step) = 1;
           end
       case 1   % Poisson-generated input
           spikes_E(step) = poisson_rnd(lambda_E, 1);
           spikes_I(step) = poisson_rnd(lambda_I, 1);
           Y(2) = Y(2) + i_0E * spikes_E(step);
           Y(3) = Y(3) + i_0I * spikes_I(step); 
       case 2   % Gamma-generated input
           spikes_E(step) = gamma_rnd(lambda_E, 3, 1);
           spikes_I(step) = gamma_rnd(lambda_I, 3, 1);
           Y(2) = Y(2) + i_0E * spikes_E(step);
           Y(3) = Y(3) + i_0I * spikes_I(step); 
   end
   switch SOLVER
       case 0
           Y = cuba_analytic(dt, Y);
       case 1
           [t,Y_T] = ode45(@cuba, [0 dt], Y);       
           Y = Y_T(end,:);      % save only last element of Y_T
       case 2
           [t,Y_T] = ode113(@cuba, [0 dt], Y);
           Y = Y_T(end,:);      % save only last element of Y_T
   end
 
   Y_Res(step,:) = Y;
   
   if (Y(1) >= V_Theta) && (T_Ela >= T_Ref)
       Y(1) = V_Rest;
       T_Ela = 0;
   end
   
   T_Ela = T_Ela + dt;
   t_curr = t_curr + dt;
   step = step + 1;
end

%% Plotting:
figure('units','normalized','outerposition',[0 0 1 1])

linewidth = 1.5;
barwidth = 0.8;
% membrane potential
subplot(3,1,1)
plot(T_Res, Y_Res(:,1), 'lineWidth', linewidth)
grid on
ylabel('V_M [mV]')
xlabel('t [ms]')

% synaptic currents
subplot(3,1,2)
plot(T_Res, Y_Res(:,2), 'lineWidth', linewidth) % excitatory synaptic current
hold on
plot(T_Res, Y_Res(:,3), 'lineWidth', linewidth) % inhibitory synaptic current
grid on
ylabel('Synaptic current [mA]')
xlabel('t [ms]')
legend('I_E', 'I_I')

% number of spikes
subplot(3,1,3)
bar(T_Res, spikes_E, 'BarWidth', barwidth)
hold on 
bar(T_Res, spikes_I, 'BarWidth', barwidth)
grid on
ylabel('n_{Spikes}')
xlabel('t [ms]')
legend('Excitatory', 'Inhibitory')