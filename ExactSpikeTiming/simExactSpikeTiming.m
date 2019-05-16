clear
%% Define Parameters
% Simulation parameters
h = 0.1;            % simulation time step
tStart = 0;
tEnd = 100;
tInput = 0;        % duration for which the input neurons fire
% Select visualization: 'RASTER', 'NEURON', 'ISI'
PLOT = 'RASTER';
% Network parameters
n = 1000;           % number of neurons
ratioExIn = 4;      % ratio excitatory to inhibitory neurons
pConn = 0.02;       % connection probability
%pConn = 0.3;
minDelay = h;       % minimal synaptic propagation delay
maxDelay = 5.0;
randDelays = false;
randWeights = false;
INTERPOLATION = 'LINEAR';

f = 0.25;     % expected firing rate of external input neurons

% Model parameters
vaParameters
factorsH = vaFactors(h);    % precalculate integration factors for time step h

% Cell array: n x (nSyn x [index, weight, delay])
synapses = createNetwork(n, pConn, ratioExIn, randWeights, randDelays, 'wEx', wEx, 'wIn', wIn);

% Initialize state memory
stateMem = zeros(n, 4, 'double');   % state variables (TEla, VM, gEx, gIn) for each neuron
tmpMem = zeros(n, 4, 'double');     % used to store copy of stateMem for the interpolation
stateMem(:,1) = tauRef;
stateMem(:,2) = EL + (VTheta - EL) * rand(n,1);
stateMem(:,3:4) = 0;

% State buffer - stores effect of spikes on state variables for each neuron
stateBufSize = max(maxDelay, ceil(tInput/h));
%stateBufSize = ceil(tInput/h);
stateBuf = PrescientBuffer(n, 3, stateBufSize);

% External input - temporary solution
inputSpikes = poissonSpikeTrain([tStart tInput], f, n);
for neuron = 1:n
    timings = round(inputSpikes{neuron} / h);
    stateBuf.add([0 wStim 0], timings, neuron);
end

spikeIndex = [];
spikeTime = [];
%VPlotIndex = ceil(n * rand);
VPlotIndex = 1;
VPlot = [];
conductanceEx = [];
conductanceIn = [];
tPlot = [];

%% Simulation loop
for t = tStart:h:tEnd  
    %% Update interval (t, t+h]
    
    tmpMem = stateMem;  % copy of stateMem(t)
      
    stateUpdate = stateBuf.read(true); % Influence of spikes in interval (t, t+h] at time t+h
  
    % Calculate subthreshold dynamics        
    idx = stateMem(:,1) <= tauRef-h | stateMem(:,1) > tauRef;   % non emerging neurons 
    stateMem(idx,:) = vaAnalytic(stateMem(idx,:), factorsH);
    stateMem(idx, 2:4) = stateMem(idx, 2:4) + stateUpdate(idx,:);
    
    % Neurons emerging from refractory period
    emergingNeurons = find(stateMem(:,1) > tauRef-h & stateMem(:,1) <= tauRef);
    % Consider neurons emerging from refractory period at t+tEm, then the
    % interval has to be split into (t, t+tEm] and (t+tEm, t+h]    
    if numel(emergingNeurons >= 1)
        tEm = stateMem(emergingNeurons, 1) + h - tauRef;
        factorsT = vaFactors(tEm);
        factorsT(1) = 0;            % time tEm already elapsed
        factorsT2 = vaFactors(h-tEm);
        gamma = tEm/h;
        for i = 1:numel(emergingNeurons)
            neuron = emergingNeurons(i);
            % update for 1st interval
            stateMem(neuron,:) = vaAnalytic(stateMem(neuron,:), factorsT(i,:));
            % stateMem(neuron, 2) = 0; -> is done in vaAnalytic already
            % update for 2nd interval
            stateMem(neuron,:) = vaAnalytic(stateMem(neuron,:), factorsT2(i,:));
            stateMem(neuron, 2:4) = stateMem(neuron, 2:4) + stateUpdate(neuron,:);
            stateMem(neuron, 2) = stateMem(neuron, 2) - gamma(i)*stateUpdate(neuron, 2);
        end
    end   
    
    % Collect spikes
    spikingNeurons = find(stateMem(:,2) > VTheta);
    
    if numel(spikingNeurons >= 1)
        % Get 'exact' spike timing for all spiking neurons
        switch INTERPOLATION
            case 'LINEAR'
                exactTiming = linearInterpolation(tmpMem(spikingNeurons, 2), stateMem(spikingNeurons, 2), VTheta, h);
            case 'QUADRATIC'
                %exactTiming = quadraticInterpolation(h, tmpMem, stateMem);
            case 'CUBIC'
                %exactTiming = cubicInterpolation(h, tmpMem, stateMem);
        end
        
        % Store spikes for raster plot
        spikeTime = [spikeTime; t + exactTiming];
        spikeIndex = [spikeIndex; spikingNeurons];

        factorsT = vaFactors(h - exactTiming);  % Calculate integration factors for each spike
        
        % Process spikes
        for i = 1:numel(spikingNeurons)
            neuron = spikingNeurons(i);

            targetNeurons = synapses{neuron}(:,1);
            % Calculate update
            weights = synapses{neuron}(:,2);
            update = zeros(numel(targetNeurons), 4);
            update(:,1) = tauRef;
            idx = weights >= 0;         % positive weights -> exc. synapse
            update(idx, 3) = weights(idx);    
            idx = weights < 0;          % negative weights -> inh. synapse
            update(weights < 0, 4) = weights(idx);     
            update = vaAnalytic(update, factorsT(i,:));
            % Update target neurons buffered state variables
%             for j = 1:numel(targetNeurons)
%                 target = targetNeurons(j);
%                 pos = round(synapses{neuron}(j, 3)/h);  % calc position in buffer dependent on propagation delay
%                 stateBuf.add(update(j,2:4), pos, target);
%             end 
            
            stateBuf.add(update(:,2:4), 0, targetNeurons);  % simplification if delay is the same for each synapse
        end    
        
        % Neurons enter refractory period
        stateMem(spikingNeurons, 1) = h-exactTiming;
        stateMem(spikingNeurons, 2) = EL; 
    end
    
    % Process input spikes
    
    if mod(t, 5) < 0.1
        fprintf('Time step t = %1.f ms\n', t)
    end
    VPlot = [VPlot stateMem(VPlotIndex,2)];
    conductanceEx = [conductanceEx stateMem(VPlotIndex, 3)];
    conductanceIn = [conductanceIn stateMem(VPlotIndex, 4)];
    tPlot = [tPlot t];
end

%% Evaluation

ISI = [];
f = [];
for i = 1:n
    idx = spikeIndex == i;
    a = diff(spikeTime(idx));
    ISI = [ISI; a];
    fI = 10^3 * numel(spikeTime(idx)) / (tEnd - tStart);
    f = [f fI];
end

VAvg = mean(stateMem(:,2));
ISIAvg = mean(ISI);
fAvg = mean(f);

%% Plotting
figure('units','normalized','outerposition',[0 0 1 1])
tPlot = tStart:h:tEnd;
linewidth = 1.5;

if PLOT == "NEURON"
    subplot(2,1,1)
    plot(tPlot, VPlot, 'lineWidth', linewidth)
    ylabel('V_M [mV]')
    xlabel('t [ms]')
    grid on
    subplot(2,1,2)
    plot(tPlot, conductanceEx, 'lineWidth', linewidth)
    hold on
    plot(tPlot, conductanceIn, 'lineWidth', linewidth)
    ylabel('Synaptic conductance [nS]')
    xlabel('t [ms]')
    legend('g_E', 'g_I')
    grid on
elseif PLOT == "RASTER"
    scatter(spikeTime, spikeIndex, 2.2, 's','MarkerEdgeColor','k','MarkerFaceColor','k')
    ylabel('neuron #')
    xlabel('t [ms]')
elseif PLOT == "ISI"
    histogram(ISI, 'Normalization','count', 'FaceColor', 'black', 'EdgeColor', 'white', 'FaceAlpha', 1.0)
    xlabel('Interspike interval [ms]')
    ylabel('Number of occurences')
    grid on
    %xlim([0 200])
elseif PLOT == "FIRINGRATE"
    histogram(f, 30, 'FaceColor', [0.184 0.333 0.592], 'EdgeColor', [0.184 0.333 0.592])
    xlabel('Firing rate [Hz]')
    ylabel('Number of occurences')
end

%% Output
fprintf("========= Average values =========\n")
fprintf("Membrane voltage:\t\t %0.2f mV\n", VAvg)
fprintf("Firing rate:\t\t\t %0.2f Hz\n", fAvg)
fprintf("Interspike interval:\t %0.2f ms\n", ISIAvg)