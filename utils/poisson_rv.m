function n = poisson_rv(lambda)
% basic idea: add up time intervals between events, which are exponentially distributed

% lambda: expected event-rate

% initialization
n = 0;
p = 1;
L = exp(-lambda);

while p > L
	p = p * rand;
	n = n + 1;
end
n = n - 1;