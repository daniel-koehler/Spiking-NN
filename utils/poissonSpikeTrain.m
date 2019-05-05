function spikeTimes = poissonSpikeTrain(tSpan, f, n)
% Generates a cell array of n poisson spike trains
% Inputs:
%   tSpan:      vector [tStart tEnd] defining time span for the returned spike times
%   f:          expected frequency per time step
%   n:          number of spike trains
% Returns:
%   spikeTimes: cell array of spike timings
spikeTimes = cell(n, 1);
fInv = 1/f;
for i = 1:n
    t = tSpan(1);
    while t < tSpan(2)
        t = t - log(rand)*fInv;     % use inverse transform sampling
        spikeTimes{i} = [spikeTimes{i} t];
    end
    if ~isempty(spikeTimes{i})
        spikeTimes{i}(end) = [];    % remove last element
    end
end

