clear
t = 0:0.01:3;
f = 103.4 * (exp(1)/0.1) * t .* exp(-t/0.01);

plot(t, f)