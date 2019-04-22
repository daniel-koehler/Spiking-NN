% Analytic solution of the neuron dynamics of a leaky integate and fire
% neuron with CUBA synapses using the matrix exponential

syms tauL tauEx tauIn RL EEx EIn VRest CM
A = [
    -1/tauL (EEx-VRest)/CM (EIn-VRest)/CM;
    0 -1/tauEx 0;
    0 0 -1/tauIn];

[V, D] = eig(A);

syms V0 gEx0 gIn0
Y = V*expm(D)/V*[V0; gEx0; gIn0]    % analytic solution

