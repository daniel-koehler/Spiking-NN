function output = poisson_rnd(lambda, m)
% Generate m Poisson distributed pseudo-random numbers. 
% Basic idea: add up time intervals between events which are exponentially
% distributed.

% lambda: expected event-rate
% m: number of returned random variables

% initialization
L = exp(-lambda);
output = zeros(1, m, 'double');

for i = 1:m
    n = 0;
    p = 1;
    while p > L
        p = p * rand;
        n = n + 1;
    end
    output(i) = n - 1;
end