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

%vogels_parameters % get model parameters
vogels_parameters


f_E = 10;       % avg. firing rate of excitatory synapse [Hz]
f_I = 10;       % avg. firing rate of inhibitory synapse [Hz]

% 4:1 ratio of excitatory to inhibitory neurons proposed by Vogels and Abbotts
n_E = 1000;     % number of excitatory synapses
n_I = 250;      % number of inhibitory synapses

%%
% INPUT_MODE = 0 - Use single spikes timed at:
t_spikes_E = [];    % timings for excitatory spikes (multiples of dt)
t_spikes_I = [];    % timings for inhibitory spikes (multiples of dt)

%%
% INPUT_MODE = 1 - Use Poisson-distributed number of EPSPs and IPSPs. Where:
% $\lambda = \frac{f}{1000 ms} \cdot dt \cdot n$
% is the expected number of spikes per simulation time step $dt$.
lambda_E = f_E / 1000 * dt * n_E;
lambda_I = f_I / 1000 * dt * n_I;

%%
% Initial condition: $U_M = -60mV, I_E = 0nA, I_I = 0nA$
Y1 = [0 0 0 0];
Y2 = [0 -60 0 0];


%%
% Variables for plotting:
spikes_E = zeros(1, t_end/dt);  % number of excitatory spikes at t
spikes_I = zeros(1, t_end/dt);  % number of inhibitory spikes at t
T_Res = t_start:dt:t_end-dt;    % time axis
Y_Res1 = Y1;                      % V_M(t), I_E(t), I_I(t)                   
Y_Res2 = Y2;                      % V_M(t), I_E(t), I_I(t)                   

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
               Y1(3) = Y1(3) + dg_E;
               Y2(3) = Y2(3) + dg_E;
               spikes_E(step) = 1;
           end
           if ismembertol(t_curr, t_spikes_I, 0.01)
               Y1(4) = Y1(4) - dg_I;
               Y2(4) = Y2(4) - dg_E;
               spikes_I(step) = 1;
           end
       case 1   % Poisson-generated input
           spikes_E(step) = poisson_rnd(lambda_E, 1);
           spikes_I(step) = poisson_rnd(lambda_I, 1);
           Y(3) = Y(3) + i_0E * spikes_E(step);
           Y(4) = Y(4) + i_0I * spikes_I(step); 
       case 2   % Gamma-generated input
           spikes_E(step) = gamma_nd(lambda_E, 3, 1);
           spikes_I(step) = gamma_rnd(lambda_I, 3, 1);
           Y(3) = Y(3) + i_0E * spikes_E(step);
           Y(4) = Y(4) + i_0I * spikes_I(step); 
   end
   switch SOLVER
       case 0
           Y1 = vogels_analytic(dt, Y1);
           %Y2 = test(dt, Y2);
       case 1
           [t,Y_T] = ode45(@cuba, [0 dt], Y);       
           Y = Y_T(end,:);      % save only last element of Y_T
       case 2
           [t,Y_T] = ode113(@cuba, [0 dt], Y);
           Y = Y_T(end,:);      % save only last element of Y_T
   end
 
   Y_Res1(step,:) = Y1;
   Y_Res2(step,:) = Y2(1);
   
%    if (Y(1) >= V_Theta) && (T_Ela >= T_Ref)
%        Y(1) = V_Rest;
%        T_Ela = 0;
%    end
   
   T_Ela = T_Ela + dt;
   t_curr = t_curr + dt;
   step = step + 1;
end

%% Plotting:
figure('units','normalized','outerposition',[0 0 1 1])

linewidth = 3;
barwidth = 0.8;
% membrane potential
% subplot(3,1,1)
plot(T_Res, Y_Res1(:,2), 'lineWidth', linewidth)
grid on
hold on 
%plot(T_Res, Y_Res2, 'lineWidth', linewidth)
ylabel('V_M [mV]')
xlabel('t [ms]')

% % synaptic currents
% subplot(3,1,2)
% plot(T_Res, Y_Res1(:,2), 'lineWidth', linewidth) % excitatory synaptic current
% hold on
% plot(T_Res, Y_Res1(:,3), 'lineWidth', linewidth) % inhibitory synaptic current
% grid on
% ylabel('Synaptic current [mA]')
% xlabel('t [ms]')
% legend('I_E', 'I_I')
% 
% % number of spikes
% subplot(3,1,3)
% bar(T_Res, spikes_E, 'BarWidth', barwidth)
% hold on 
% bar(T_Res, spikes_I, 'BarWidth', barwidth)
% grid on
% ylabel('n_{Spikes}')
% xlabel('t [ms]')
% legend('Excitatory', 'Inhibitory')