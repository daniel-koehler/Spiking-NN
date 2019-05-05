clear
%% Define Parameters
% Simulation parameters
dt = 0.1;   
t_start = 0;
t_end = 100;
t_input = 50;       % duration for which the input neurons fire

% Network parameters
n = 1;           % number of neurons
ratio_EI = 4;       % ratio excitatory to inhibitory neurons
n_E = round((n * ratio_EI)/(ratio_EI + 1));
n_I = n - n_E;
lambda = 0.25;       % expected firing rate of external input neurons
p_conn = 0.02;      % connection probability

% Model parameters
vogels_parameters

% choose visualization: NEURON, RASTER, ISI, FIRINGRATE
PLOT = "NEURON";


%% Initialize network
% storage of connections:
% E.g. neuron 4 is connected to neurons with indices 20 and 267, then
% connections{i} = [20 267]
connections = cell(n, 1);
n_syn = round((n-1)*p_conn);
for i = 1:n
    connections{i} = ceil(n*rand(1,n_syn));
end

Y = zeros(n, 3, 'double'); % state values of each neuron (V_M, g_E, g_I)
% initialize membrane voltage randomly
Y(:,1) = V_Rest + (V_Theta - V_Rest) * rand(n,1);
Y(:,2) = 0;
Y(:,3) = 0;

spikes_E = [];             % contains indices of neurons spiking at current time step
spikes_I = [];
t_ela = zeros(1, n);       % contains time elapsed since last spike for each neuron
t_ela(:) = T_Ref;

% Variables for plotting
raster_index = [];
t_raster = [];
voltage = [];
conductance_E = [];
conductance_I = [];
spike_times = cell(n, 1);

input_spikes = zeros(n,ceil((t_input-t_start)/dt));
% for i = 1:n
%     input_spikes(i,:) = poisson_rnd(lambda, ceil((t_input-t_start)/dt));
% end
%inputSpikes = poissonSpikeTrain([tStart tInput], f, n);

step = 1;
%% Simulation loop
for t = t_start:dt:t_end    
    % External stimulation
    if t < t_input
        %Y(:,2) = Y(:,2) + dg_E * input_spikes(:, step);
        Y(:,2) = Y(:,2) + 5 * input_spikes(:, step);
        step = step + 1;
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
    Y = vogels_analytic(dt, Y);
    for i = 1:n 
        if (t_ela(i) < T_Ref)           % clamp to resting potential
            Y(i, 1) = V_Rest;        
        elseif (Y(i, 1) >= V_Theta)     % neuron spiking?
            if i <= n_E
                spikes_E = [spikes_E i];
            else               
                spikes_I = [spikes_I i];
            end
            spike_times{i} = [spike_times{i} t];

        end        
    end
    Y([spikes_E spikes_I], 1) = V_Rest;
    t_ela([spikes_E spikes_I]) = 0;
    
    t_ela = t_ela + dt;
    
    % raster plot
    raster_index = [raster_index spikes_E spikes_I];
    s = size([spikes_E spikes_I]);
    t_raster = [t_raster repmat(t, [1, s(2)])];    
    voltage  = [voltage Y(1,1)];
    conductance_E  = [conductance_E Y(1,2)];    
    conductance_I  = [conductance_I Y(1,3)];
end

% get interspike intervals and firing rate per neuron
ISI = [];
f = [];
for i = 1:n
    ISI = [ISI diff(spike_times{i})];
    s = size(spike_times{i});
    f_i = 10^3 * s(2) / (t_end - t_start);
    f = [f f_i];
end

V_avg = mean(Y(:,1));
ISI_avg = mean(ISI);
f_avg = mean(f);

%% Plotting
figure('units','normalized','outerposition',[0 0 1 1])
t_plot = t_start:dt:t_end;
linewidth = 1.5;

if PLOT == "NEURON"
    subplot(2,1,1)
    plot(t_plot, voltage, 'lineWidth', linewidth)
    ylabel('V_M [mV]')
    xlabel('t [ms]')
    grid on
    subplot(2,1,2)
    plot(t_plot, conductance_E, 'lineWidth', linewidth)
    hold on
    plot(t_plot, conductance_I, 'lineWidth', linewidth)
    ylabel('Synaptic conductance [nS]')
    xlabel('t [ms]')
    legend('I_E', 'I_I')
    grid on
elseif PLOT == "RASTER"
    scatter(t_raster, raster_index, 2.2, 's','MarkerEdgeColor','k','MarkerFaceColor','k')
    ylabel('neuron #')
    xlabel('t [ms]')
elseif PLOT == "ISI"
    histogram(ISI, 'Normalization','probability', 'FaceColor', [0.184 0.333 0.592], 'EdgeColor', [0.184 0.333 0.592])
    xlabel('Interspike interval [ms]')
    ylabel('#')
    grid on
    %xlim([0 200])
elseif PLOT == "FIRINGRATE"
    histogram(f, 30, 'FaceColor', [0.184 0.333 0.592], 'EdgeColor', [0.184 0.333 0.592])
    xlabel('Firing rate [Hz]')
    ylabel('#')
end

%% Output
fprintf("========= Average values =========\n")
fprintf("Membrane voltage:\t\t %0.2f mV\n", V_avg)
fprintf("Firing rate:\t\t\t %0.2f Hz\n", f_avg)
fprintf("Interspike interval:\t %0.2f ms\n", ISI_avg)