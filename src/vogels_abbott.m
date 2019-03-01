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
n = 5000;           % number of neurons
ratio_EI = 4;       % ratio excitatory to inhibitory neurons
n_E = round((n * ratio_EI)/(ratio_EI + 1));
n_I = n - n_E;
lambda = 0.6;       % expected firing rate of external input neurons
p_conn = 0.02;      % connection probability

% Model parameters
cuba_parameters     

%% Initialize network

% storage of connections:
% E.g. neuron 4 is connected to neurons with indices 20 and 267, then
% connections{i} = [20 267]
connections = cell(n, 1);
tic
for i = 1:round(n^2 * p_conn)
    index_pre = ceil(n * rand);
    index_post = ceil(n * rand);        % neuron can still be connected to itself!!!
    
    connections{index_pre} = [connections{index_pre} index_post];
end

toc

Y = zeros(n, 3, 'double');           % contains state values of each neuron
%Y(:,1) = V_Rest;

Y(:,1) = V_Rest + 9*rand(n,1);
Y(:,2) = 3*rand(n,1);
Y(:,2) = 2*rand(n,1);

spikes_E = [];             % contains indices of neurons spiking at current time step
spikes_I = [];
t_ela = zeros(1, n);       % contains time elapsed since last spike of each neuron
t_ela(:) = T_Ref;

spike_raster = cell((t_end - t_start)*dt, 1);
index = [];
t_raster = [];

test_plot = [];
test_plot1 = [];
%% Simulation loop
step = 1;
toc
for t = t_start:dt:t_end    
    % External stimulation
    if t <= t_input
        Y(:,2) = Y(:,2) + i_0E * transpose(poisson_rnd(lambda, n));
    end 
    % Internal stimulation
    for spike = spikes_E
        Y(connections{spike}, 2) = Y(connections{spike}, 2) + i_0E;
    end
    for spike = spikes_I
        Y(connections{spike}, 3) = Y(connections{spike}, 3) + i_0I;
    end
    spikes_E = [];
    spikes_I = [];
    % Outputs
    % optimierungsbedarf hier
    Y = cuba_analytic(dt, Y);
    for i = 1:n 
        if (Y(i, 1) >= V_Theta) && (t_ela(i) >= T_Ref)  % neuron spiking?
            if i <= n_E
                spikes_E = [spikes_E i];
            else               
                spikes_I = [spikes_I i];
            end
            index = [index i];
            t_raster = [t_raster t];
            Y(i, 1) = V_Rest;
            t_ela(i) = 0;
        end        
    end
    spike_raster{step} = [spikes_E spikes_I];
    step = step + 1;
    t_ela = t_ela + dt;
    test_plot  = [test_plot Y(45,1)];
    test_plot1  = [test_plot1 Y(45,2)];    
end
toc

figure('units','normalized','outerposition',[0 0 1 1])
% t_plot = t_start:dt:t_end;
% subplot(3,1,1)
% plot(t_plot, test_plot)
% subplot(3,1,2)
% plot(t_plot, test_plot1)
% subplot(3,1,3)
scatter(t_raster, index, 2, 's','MarkerEdgeColor','k','MarkerFaceColor','k')