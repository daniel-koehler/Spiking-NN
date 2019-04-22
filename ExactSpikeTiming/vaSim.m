clear
%% Define Parameters
% Simulation parameters
h = 0.1;            % simulation time step
tStart = 0;
tEnd = 100;
tInput = 50;        % duration for which the input neurons fire
% Network parameters
n = 1000;           % number of neurons
ratioExIn = 4;      % ratio excitatory to inhibitory neurons
pConn = 0.02;       % connection probability
minDelay = h;       % minimal synaptic propagation delay
maxDelay = 5.0;
randDelays = false;
randWeights = false;
INTERPOLATION = 'linear';

f = 0.25;     % expected firing rate of external input neurons

% Model parameters
vaParameters
factorsH = vaFactors(h);    % precalculate integration factors for time step h

% Cell array: n x (nSyn x [index, weight, delay])
synapses = createNetwork(n, pConn, ratioExIn, randWeights, randDelays);

% Initialize state memory
stateMem = zeros(n, 4, 'double');   % state variables (TEla, VM, gEx, gIn) for each neuron
tmpMem = zeros(n, 4, 'double');     % used to store copy of stateMem for the interpolation
stateMem(:,1) = tauRef;
stateMem(:,2) = EL + (VTheta - EL) * rand(n,1);
stateMem(:,3:4) = 0;

% State buffer - stores effect of spikes on state variables for each neuron
%stateBufSize = ceil(maxDelay / h);
stateBufSize = ceil(tInput / h);
stateBuf = PrescientBuffer(n, 3, stateBufSize);

% External input - temporary solution
inputSpikes = poissonSpikeTrain([tStart tInput], f, n);
for neuron = 1:n
    timings = round(inputSpikes{neuron} / h);
    stateBuf.add([0 wEx 0], timings, neuron);
    %stateBuf.add([0 wEx 0], timings, neuron);
end

spikeIndex = [];
spikeTime = [];
VPlotIndex = ceil(n * rand);
VPlot = [];
tPlot = [];

% Simulation loop
for t = tStart:h:tEnd  
    tmpMem = stateMem;
    
%     stateMem(:, 2:4) = stateMem(:, 2:4) + stateBuf.read(true);
%     stateMem = vaAnalytic(stateMem, factorsH);
   
    
    % Update state memory
    stateUpdate = stateBuf.read(true);

    
    % Calculate subthreshold dynamics    
    idx = find(stateMem(:,1) >= tauRef);       % non emerging neurons
    stateMem(idx,:) = vaAnalytic(stateMem(idx,:), factorsH);
    stateMem(idx, 2:4) = stateMem(idx, 2:4) + stateUpdate(idx,:);
    
    % Neurons emerging from refractory period
    emergingNeurons = find(stateMem(:,1) >= tauRef-h & stateMem(:,1) < tauRef);
    % Consider the neurons emerge from refractory period at t+tEm, then the
    % interval has to be split into (t, t+tEm] and (t+tEm, t+tEm+h]    
    if numel(emergingNeurons >= 1)
        tEm = tauRef-stateMem(emergingNeurons, 1);
        factorsT = vaFactors(tEm);
        factorsT2 = vaFactors(h-tEm);
        gamma = tEm/h;
        for i = 1:numel(emergingNeurons)
            neuron = emergingNeurons(i);
            % update for 1st interval
            stateMem(neuron,:) = vaAnalytic(stateMem(neuron,:), factorsT(i,:));
            stateMem(neuron, 2) = 0;
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
            case 'linear'
                exactTiming = linearInterpolation(tmpMem(spikingNeurons, 2), stateMem(spikingNeurons, 2), VTheta, h);
            case 'quadratic'
                exactTiming = quadraticInterpolation(h, tmpMem, stateMem);
            case 'cubic'
                exactTiming = cubicInterpolation(h, tmpMem, stateMem);
        end
        % Neurons entering refractory period
        stateMem(spikingNeurons, 1) = h-exactTiming;
        stateMem(spikingNeurons, 2) = EL;
        
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
            
            stateBuf.add(update(:,2:4), 0, targetNeurons);
        end    
        
        
        
        
        
    end
    
%     if mod(t, 5) < 0.1
%         t
%     end
    VPlot = [VPlot stateMem(VPlotIndex,2)];
    tPlot = [tPlot t];
end

scatter(spikeTime, spikeIndex, 2, 's','MarkerEdgeColor','k','MarkerFaceColor','k')
ylabel('neuron #')
xlabel('t [ms]')
% plot(tPlot, VPlot, 'lineWidth', 1.5)
% ylabel('V_M [mV]')
% xlabel('t [ms]')



