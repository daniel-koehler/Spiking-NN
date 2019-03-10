%vectorize instead of loops
%preallocate
%mat file for data?

clear

% Simulation parameters
dt = 0.1;   
t_start = 0;
t_end = 100;
t_input = 50;       % duration for which the input neurons fire

% Network parameters
n = 10000;           % number of neurons
ratio_EI = 4;       % ratio excitatory to inhibitory neurons
n_E = round((n * ratio_EI)/(ratio_EI + 1));
n_I = n - n_E;
lambda = 0.025;       % expected firing rate of external input neurons
p_conn = 0.02;      % connection probability

% Model parameters
cuba_parameters     

%% Initialize network

% storage of connections:
% E.g. neuron 4 is connected to neurons with indices 20 and 267, then
% connections{i} = [20 267]
connections = cell(n, 1);
n_syn = round((n-1)*p_conn);
for i = 1:n
    connections{i} = ceil(n*rand(1,n_syn));
end

Y = zeros(n, 3, 'double');           % contains state values of each neuron
Y(:,1) = V_Rest;

%Y(:,1) = V_Rest + 10*rand(n,1);
%Y(:,2) = 0.3*rand(n,1);
%Y(:,2) = 0.6*rand(n,1);

spikes_E = [];             % contains indices of neurons spiking at current time step
spikes_I = [];
t_ela = zeros(1, n);       % contains time elapsed since last spike of each neuron
t_ela(:) = T_Ref;

index = [];
t_raster = [];

voltage = [];
conductance_E = [];
conductance_I = [];

%% Simulation loop
tic
for t = t_start:dt:t_end    
    % External stimulation
    if t <= t_input
        Y(:,2) = Y(:,2) + dg_E * transpose(poisson_rnd(lambda, n));
    end 
    % Internal stimulation
    for spike = spikes_E
        Y(connections{spike}, 2) = Y(connections{spike}, 2) + dg_E;
    end
    for spike = spikes_I
        Y(connections{spike}, 3) = Y(connections{spike}, 3) + dg_I;
    end
     
    spikes_E = [];
    spikes_I = [];
    
    % Outputs
    Y = cuba_analytic(dt, Y);
    for i = 1:n 
        if (Y(i, 1) >= V_Theta) && (t_ela(i) >= T_Ref)  % neuron spiking?
            if i <= n_E
                spikes_E = [spikes_E i];
            else               
                spikes_I = [spikes_I i];
            end
        end        
    end
    Y([spikes_E spikes_I], 1) = V_Rest;
    t_ela([spikes_E spikes_I]) = 0;
    
    index = [index spikes_E spikes_I];
    s = size([spikes_E spikes_I]);
    t_raster = [t_raster repmat(t, [1, s(2)])];
    t_ela = t_ela + dt;
    voltage  = [voltage Y(45,1)];
    conductance_E  = [conductance_E Y(45,2)];    
    conductance_I  = [conductance_I Y(45,3)];
end
toc

figure('units','normalized','outerposition',[0 0 1 1])
t_plot = t_start:dt:t_end;
subplot(3,1,1)
plot(t_plot, voltage)
subplot(3,1,2)
plot(t_plot, conductance_E)
hold on
plot(t_plot, conductance_I)
subplot(3,1,3)
scatter(t_raster, index, 2, 's','MarkerEdgeColor','k','MarkerFaceColor','k')
