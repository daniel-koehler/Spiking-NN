function output = gamma_rnd(lambda, alpha, m)
% Generate m Gamma distributed pseudo-random numbers.

output = int16.empty(m, 0);

for i = 1:m
    p = 1;
    for k = 1:alpha
        p = p * rand;
    end
    output(i) = -log(p)*lambda/alpha;
end