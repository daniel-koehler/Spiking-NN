function neurons = createNetwork(n, pConn, ratioExIn, varargin)
% Create a network of n neurons with fixed connection probability, synaptic
% strengths and propagation delay.
% Inputs:
%   n:              number of neurons in the network
%   pConn:          connection probability between the neurons
%   ratioExIn:      ratio of excitatory to inhibitory neurons
% Optional inputs:
%   randWeight:     false (default): all weights are set to wEx/wIn
%                   true: weights are equally distributed over the
%                   interval (0, wEx) or (0, wIn) respectively
%   randDelay:      false (default): all delays are set to minDelay
%                   true: weights are equally distributed over the
%                   interval (minDelay, maxDelay)
% Parameters:
%   minDelay:       minimum synaptic propagation delay (default: 0.1)
%   maxDelay:       maximum synaptic propagation delay (default: 0.1)
%   wEx:            synaptic strength for excitatory synapses (default: 1)
%   wIn:            synaptic strength for inhibitory synapses (default: -1)
% Returns:
%   neurons:        cell array with n rows (one row per neuron) containing
%                   a matrice each. The columns of the matrice correspond 
%                   to target neuron index, weight and delay of a synapse.

% parse input arguments
p = inputParser;
p.addRequired('n',@isnumeric);
p.addRequired('pConn',@isnumeric);
p.addRequired('ratioExIn',@isnumeric);
p.addOptional('randWeight', false, @islogical);
p.addOptional('randDelay', false, @islogical);
p.addParameter('wEx', 1, @isnumeric);
p.addParameter('wIn', -1, @isnumeric);
p.addParameter('minDelay', 0.1, @isnumeric);
p.addParameter('maxDelay', 0.1, @isnumeric);
p.parse(n, pConn, ratioExIn, varargin{:});
n = p.Results.n;

nEx = round((n * ratioExIn)/(ratioExIn + 1));
nSyn = round((n-1)*pConn);

neurons = cell(n, 1);
weights = zeros(nSyn, 1);
delays = zeros(nSyn, 1);
delays(:) = p.Results.minDelay;

% excitatory neurons
weights(:) = p.Results.wEx;
for i = 1:nEx       
    if p.Results.randWeight
        weights = p.Results.wEx * rand(nSyn, 1);
    end
    if p.Results.randDelay
        delays = rand(nSyn, 1)*(p.Results.maxDelay-p.Results.minDelay) + p.Results.minDelay;
    end
    indices = ceil(n*rand(nSyn, 1));
    neurons{i} = [indices, weights, delays];
end
% inhibitory neurons
weights(:) = p.Results.wIn;
for i = nEx+1:n     
    if p.Results.randWeight
        weights = p.Results.wIn * rand(nSyn, 1);
    end
    if p.Results.randDelay
        delays = rand(nSyn, 1)*(p.Results.maxDelay-p.Results.minDelay) + p.Results.minDelay;
    end
    indices = ceil(n*rand(nSyn, 1));
    neurons{i} = [indices, weights, delays];
end

end