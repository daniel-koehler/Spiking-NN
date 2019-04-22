clear all;
VM0 = 0;
gEx0 = 0.27;
vaParameters;
dt = 0.1;
t = 0:dt:100;
% t1 = 5;
% t2 = 10;
t1 = 3;
t2 = 12;
idx1 = t1/dt+1;
idx2 = t2/dt+1;

% membrane voltage
VM = VM0 * exp(-tauL*t) + gEx0 * (EAvg - EEx) * RL * tauL / (tauL - tauEx) * (exp(-tauL * t)-exp(-tauEx * t));
% 1st derivative
dVM = -tauL * exp(-tauL * t) * VM0 + gEx0 * (EAvg - EEx) * RL * tauL / (tauL - tauEx) * (-tauL * exp(-tauL * t) + tauEx * exp(-tauEx * t));
% 2nd derivative
ddVM = tauL^2 * exp(-tauL * t) * VM0 + gEx0 * (EAvg - EEx) * RL * tauL / (tauL - tauEx) * (tauL^2 * exp(-tauL * t) - tauEx^2 * exp(-tauEx * t));
% 3rd derivative
dddVM = -tauL^3 * exp(-tauL * t) * VM0 + gEx0 * (EAvg - EEx) * RL * tauL / (tauL - tauEx) * (-tauL^3 * exp(-tauL * t) + tauEx^3 * exp(-tauEx * t));
% linear interpolation
int1 = (VM(idx2)-VM(idx1))/(t2 - t1) * (t-t1) + VM(idx1);
% quadratic interpolation
int2 = (VM(idx2)/(t2-t1)^2 - VM(idx1)/(t2-t1)^2 - dVM(idx1)/(t2-t1)) * (t-t1).^2 + dVM(idx1) * (t-t1) + VM(idx1);
% cubic interpolation
a3 = 2*VM(idx1)/(t2-t1)^3 - 2*VM(idx2)/(t2-t1)^3 + dVM(idx1)/(t2-t1)^2 + dVM(idx2)/(t2-t1)^2;
a2 = 3*VM(idx2)/(t2-t1)^2 - 3*VM(idx1)/(t2-t1)^2 - 2*dVM(idx1)/(t2-t1) - dVM(idx2)/(t2-t1);
a1 = dVM(idx1);
a0 = VM(idx1);
int3 = a3 * (t-t1).^3 + a2 * (t-t1).^2 + a1 * (t-t1) + a0;
% quartic interpolation
a4 = 3*VM(idx1)/(t2-t1)^4 - 3*VM(idx2)/(t2-t1)^4 + 2*dVM(idx1)/(t2-t1)^3 + dVM(idx2)/(t2-t1)^3 + ddVM(idx1)/(t2-t1)^2;
a3 = 4*VM(idx2)/(t2-t1)^3 - 4*VM(idx1)/(t2-t1)^3 - 3*dVM(idx1)/(t2-t1)^2 - dVM(idx2)/(t2-t1)^2 - 2*ddVM(idx1)/(t2-t1);
a2 = ddVM(idx1);
a1 = dVM(idx1);
a0 = VM(idx1);
int4 = a4 * (t-t1).^4 + a3 * (t-t1).^3 + a2 * (t-t1).^2 + a1 * (t-t1) + a0;
% % quintic interpolation
% a5 = (6*Vh)/h^5 - (6*V0)/h^5 - (3*dV0)/h^4 - (3*dVh)/h^4 - ddV0/h^3 + ddVh/(2*h^3);
% a4 = (15*V0)/h^4 - (15*Vh)/h^4 + (8*dV0)/h^3 + (7*dVh)/h^3 + (3*ddV0)/h^2 - ddVh/h^2;
% a3 = (10*Vh)/h^3 - (10*V0)/h^3 - (6*dV0)/h^2 - (4*dVh)/h^2 - (3*ddV0)/h + ddVh/(2*h);
% a2 = ddV0;
% a1 = dV0;
% a0 = V0;
% % sextic interpolation
% a6 = (10*Vh)/h^6 - (10*V0)/h^6 - (6*dV0)/h^5 - (4*dVh)/h^5 - (3*ddV0)/h^4 + ddVh/(2*h^4) - dddV0/h^3;
% a5 = (24*V0)/h^5 - (24*Vh)/h^5 + (15*dV0)/h^4 + (9*dVh)/h^4 + (8*ddV0)/h^3 - ddVh/h^3 + (3*dddV0)/h^2;
% a4 = (15*Vh)/h^4 - (15*V0)/h^4 - (10*dV0)/h^3 - (5*dVh)/h^3 - (6*ddV0)/h^2 + ddVh/(2*h^2) - (3*dddV0)/h;
% a3 = dddV0;
% a2 = ddV0;
% a1 = dV0;
% a0 = V0;
% 
% % septic interpolation
% a7 = (20*V0)/h^7 - (20*Vh)/h^7 + (10*dV0)/h^6 + (10*dVh)/h^6 + (4*ddV0)/h^5 - (2*ddVh)/h^5 + dddV0/h^4 + dddVh/(6*h^4);
% a6 = (70*Vh)/h^6 - (70*V0)/h^6 - (36*dV0)/h^5 - (34*dVh)/h^5 - (15*ddV0)/h^4 + (13*ddVh)/(2*h^4) - (4*dddV0)/h^3 - dddVh/(2*h^3);
% a5 = (84*V0)/h^5 - (84*Vh)/h^5 + (45*dV0)/h^4 + (39*dVh)/h^4 + (20*ddV0)/h^3 - (7*ddVh)/h^3 + (6*dddV0)/h^2 + dddVh/(2*h^2);
% a4 = (35*Vh)/h^4 - (35*V0)/h^4 - (20*dV0)/h^3 - (15*dVh)/h^3 - (10*ddV0)/h^2 + (5*ddVh)/(2*h^2) - (4*dddV0)/h - dddVh/(6*h);
% a3 = dddV0;
% a2 = ddV0;
% a1 = dV0;
% a0 = V0;
% quintic interpolation
a5 = (6*VM(idx2))/(t2-t1)^5 - (6*VM(idx1))/(t2-t1)^5 - (3*dVM(idx1))/(t2-t1)^4 - (3*dVM(idx2))/(t2-t1)^4 - ddVM(idx1)/(t2-t1)^3 + ddVM(idx2)/(2*(t2-t1)^3);
a4 = (15*VM(idx1))/(t2-t1)^4 - (15*VM(idx2))/(t2-t1)^4 + (8*dVM(idx1))/(t2-t1)^3 + (7*dVM(idx2))/(t2-t1)^3 + (3*ddVM(idx1))/(t2-t1)^2 - ddVM(idx2)/(t2-t1)^2;
a3 = (10*VM(idx2))/(t2-t1)^3 - (10*VM(idx1))/(t2-t1)^3 - (6*dVM(idx1))/(t2-t1)^2 - (4*dVM(idx2))/(t2-t1)^2 - (3*ddVM(idx1))/(t2-t1) + ddVM(idx2)/(2*(t2-t1));
a2 = ddVM(idx1);
a1 = dVM(idx1);
a0 = VM(idx1);
int5 = a5 * (t-t1).^5 + a4 * (t-t1).^4 + a3 * (t-t1).^3 + a2 * (t-t1).^2 + a1 * (t-t1) + a0;

% sextic interpolation
a6 = (10*VM(idx2))/(t2-t1)^6 - (10*VM(idx1))/(t2-t1)^6 - (6*dVM(idx1))/(t2-t1)^5 - (4*dVM(idx2))/(t2-t1)^5 - (3*ddVM(idx1))/(t2-t1)^4 + ddVM(idx2)/(2*(t2-t1)^4) - dddVM(idx1)/(t2-t1)^3;
a5 = (24*VM(idx1))/(t2-t1)^5 - (24*VM(idx2))/(t2-t1)^5 + (15*dVM(idx1))/(t2-t1)^4 + (9*dVM(idx2))/(t2-t1)^4 + (8*ddVM(idx1))/(t2-t1)^3 - ddVM(idx2)/(t2-t1)^3 + (3*dddVM(idx1))/(t2-t1)^2;
a4 = (15*VM(idx2))/(t2-t1)^4 - (15*VM(idx1))/(t2-t1)^4 - (10*dVM(idx1))/(t2-t1)^3 - (5*dVM(idx2))/(t2-t1)^3 - (6*ddVM(idx1))/(t2-t1)^2 + ddVM(idx2)/(2*(t2-t1)^2) - (3*dddVM(idx1))/(t2-t1);
a3 = dddVM(idx1);
a2 = ddVM(idx1);
a1 = dVM(idx1);
a0 = VM(idx1);
int6 = a6 * (t-t1).^6 + a5 * (t-t1).^5 + a4 * (t-t1).^4 + a3 * (t-t1).^3 + a2 * (t-t1).^2 + a1 * (t-t1) + a0;

% septic interpolation
a7 = (20*VM(idx1))/(t2-t1)^7 - (20*VM(idx2))/(t2-t1)^7 + (10*dVM(idx1))/(t2-t1)^6 + (10*dVM(idx2))/(t2-t1)^6 + (4*ddVM(idx1))/(t2-t1)^5 - (2*ddVM(idx2))/(t2-t1)^5 + dddVM(idx1)/(t2-t1)^4 + dddVM(idx2)/(6*(t2-t1)^4);
a6 = (70*VM(idx2))/(t2-t1)^6 - (70*VM(idx1))/(t2-t1)^6 - (36*dVM(idx1))/(t2-t1)^5 - (34*dVM(idx2))/(t2-t1)^5 - (15*ddVM(idx1))/(t2-t1)^4 + (13*ddVM(idx2))/(2*(t2-t1)^4) - (4*dddVM(idx1))/(t2-t1)^3 - dddVM(idx2)/(2*(t2-t1)^3);
a5 = (84*VM(idx1))/(t2-t1)^5 - (84*VM(idx2))/(t2-t1)^5 + (45*dVM(idx1))/(t2-t1)^4 + (39*dVM(idx2))/(t2-t1)^4 + (20*ddVM(idx1))/(t2-t1)^3 - (7*ddVM(idx2))/(t2-t1)^3 + (6*dddVM(idx1))/(t2-t1)^2 + dddVM(idx2)/(2*(t2-t1)^2);
a4 = (35*VM(idx2))/(t2-t1)^4 - (35*VM(idx1))/(t2-t1)^4 - (20*dVM(idx1))/(t2-t1)^3 - (15*dVM(idx2))/(t2-t1)^3 - (10*ddVM(idx1))/(t2-t1)^2 + (5*ddVM(idx2))/(2*(t2-t1)^2) - (4*dddVM(idx1))/(t2-t1) - dddVM(idx2)/(6*(t2-t1));
a3 = dddVM(idx1);
a2 = ddVM(idx1);
a1 = dVM(idx1);
a0 = VM(idx1);
int7 = a7 * (t-t1).^7 + a6 * (t-t1).^6 + a5 * (t-t1).^5 + a4 * (t-t1).^4 + a3 * (t-t1).^3 + a2 * (t-t1).^2 + a1 * (t-t1) + a0;

figure('units','normalized','outerposition',[0 0 1 1])
plot(t,VM, 'linewidth', 2, 'color', 'black');
grid on

ylabel('Membrane voltage [mV]');
xlabel('Time [ms]');
hold on;
linewidth = 2;
plot(t, int1, '--', 'linewidth', linewidth, 'color', 'black')
plot(t, int2, ':', 'linewidth', linewidth, 'color', 'black')
plot(t, int3, '-.', 'linewidth', linewidth, 'color', 'black')
% plot(t, int4, 'linewidth', linewidth)
% plot(t, int5, 'linewidth', linewidth)
% plot(t, int6, 'linewidth', linewidth)
% plot(t, int7, 'linewidth', linewidth)


legend('Membrane voltage', '1^{st} order', '2^{nd} order', '3^{rd} order', 'Location', 'southeast')%, '4^{th} order', '5^{th} order', '6^{th} order','7^{th} order', 'Location', 'southeast')
xlim([0 15]);
ylim([0.1 0.3]);
line([t1 t1], [0 0.3], 'Color', 'black', 'linewidth', 2, 'HandleVisibility', 'off');
line([t2 t2], [0 0.3], 'Color', 'black', 'linewidth', 2, 'HandleVisibility', 'off');
