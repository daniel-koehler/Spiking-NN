function n = poisson_rv2(lambda)
% basic idea: add up time intervals between events, which are exponentially distributed

% lambda: expected event-rate

% initialization
n = 0;
t = 0;

while t < 1
	dt = - ln(1-rand)/lambda;
	t = t + dt;
	n = n + 1;
end
n = n - 1;