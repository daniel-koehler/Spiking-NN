function output = poisson_rnd_delay(lambda, t_delay, m)
% lambda: expected event-rate
% t_delay: delay time (shifting distribution)
% m: number of returned random variables

output = int16.empty(m, 0);
n = 0;
t = 0;
for i = 1:m
    while t < 1
        dt = t_delay - log(rand)/lambda;
        t = t + dt;
        n = n + 1;
    end
    output(i) = n - 1;
end