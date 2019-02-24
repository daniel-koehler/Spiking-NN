clear
clf

% number of Poisson distributed numbers 
n = 10000;
lambda = 100;

% generate random values
%rvsa = poissrnd(lambda, 1, n(1));
%rvsb = gamrnd(3,1, n);
rvsa = gamma_rnd(lambda, 2, n);


% average
avg_rvsa = mean(rvsa)
%avg_rvsb = mean(rvsb);

% plot histograms
histogram(rvsa)
str = sprintf('n = %d', n);
title(str);



