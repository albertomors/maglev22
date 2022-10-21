%{
    ...
    6) after modelling all the components this tool compute the equilibrium
    on the final system [code is recursive so you can pro-compute every run
    with increased precision reducing the range and re-using the results
    from the last run.
%}

clear; close all;
addpath('../maglevFunctions');
load('params.mat');
load('results.mat')

approximationType = input("approxType [0/1]> ");

%% Searching parameters [EDIT HERE]
min_height = .05;
max_height = .07;
height_steps = 64;

if(approximationType == 0)
    eq = results.zeq.zeq_fst;
    params.magnets.I = results.neo_vs_neo.curr_fst;
    params.levitatingmagnet.I = results.neo_vs_lev.curr_fst;
else
    eq = results.zeq.zeq_acc;
    params.magnets.I = results.neo_vs_neo.curr_acc;
    params.levitatingmagnet.I = results.neo_vs_lev.curr_acc;
end

x0 = zeros(12,1); x0(3) = eq;
sys = maglevSystem(x0, params, approximationType);

%% Plot maglevSystem
figure(1)
grid on; hold on; daspect([1,1,1]); view([47,15]);
draw(sys, 'fancy'); hold off;

%% Plot z
Zrs = linspace(min_height,max_height,height_steps);
Fzs = zeros(size(Zrs));

h = waitbar(0);
for i = 1:length(Zrs)
    temp = sys.f([0,0,Zrs(i),zeros(1,9)]',zeros(params.solenoids.N,1));
    Fzs(i) = temp(9);
    waitbar(i/length(Zrs))
end
close(h);

figure(2)
plot(Zrs,Fzs);
grid minor; yline(0,'k--');
axis([min_height max_height -30 30]);

[~,idx]=min(abs(Fzs-0));
best_zeq = Zrs(idx);
fprintf("z_eq found: %f m\n", best_zeq);
xline(best_zeq,'r--');

% save results for next run
if(approximationType == 0)
    results.zeq.zeq_fst = best_zeq;
else
    results.zeq.zeq_acc = best_zeq;
end
save 'results.mat' results