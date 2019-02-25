% ISI distribution for n input neurons

% Here the interspike intervals (ISI) of each neuron are exponentially distributed with a delay time:
% t_i = t_delay - 1\lambda ln(U_i), where U_i is uniformly distributed on (0, 1).
n = 10;        % number of input neurons / spike generators
t_end = 100;    % simulation time [ms]
lambda = 1;     % expected spikes per 
t_delay = 5;    % refractory time [ms]
timings = [];

for i = 1:n
    t = rand * t_delay;     % prevent that neurons enter the refractory period synchronized
    while 1
        dt = t_delay - log(rand)/lambda;
        t = t + dt;
        if t > t_end
            break
        end
        timings(end+1) = t;
    end
end

timings = sort(timings);
ISI = diff(timings);

% Plotting
x_min = 0;
x_max = max(ISI);

subplot(2,1,1)
histogram(ISI)
xlim([x_min x_max])
mean(ISI)
var(ISI)
grid on

subplot(2,1,2)
x = x_min:1/n:x_max;
dist = pdf(fitdist(transpose(ISI), 'Exponential'), x);
plot(x, dist)
xlim([x_min x_max])
grid on