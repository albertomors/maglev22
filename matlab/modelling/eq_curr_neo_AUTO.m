%{
    Author: Alberto Morselli
    Project: maglev22 - https://github.com/albertomors/maglev22

    1) ...
    2) Auto-search to optimize precision after have found manually a good starting point
    with eq_current_neo.m
    3) ...
    4) ...
    5) ...
%}

clear; close all;
addpath('../maglevFunctions');
load('params.mat');
load('results.mat');
meas_height = results.neo_vs_neo.meas_height;

approximationType = input("approxType [0/1]> ");

%% Searching parameters [EDIT HERE]
min_height = .065;
max_height = .085;
height_steps = 32;

if(approximationType == 0)
    last_curr = results.neo_vs_neo.curr_fst;
else
    last_curr = results.neo_vs_neo.curr_acc;
end

current_range = 10; % Ampere around stimated correct value
min_current = last_curr-current_range/2;
max_current = last_curr+current_range/2;
current_steps = 32;

%% Overwrite solenoid parameters
params.solenoids.ri = 0;
params.solenoids.ro = 0; % ...and don't draw it

%% Overwrite neodymium magnets parameters as a single centered one
params.magnets.N = 1; % just one...
params.magnets.R = 0; % ...placed at center

%% Overwrite floating magnet parameters as a neodymium magnet
params.levitatingmagnet = params.magnets;

%% Finding the zero point for z graphs with different set currents
test_current = linspace(min_current,max_current,current_steps);
Fzs = zeros(size(test_current)); % array to store corresponding forces @ meas_height
x0 = zeros(12,1); x0(3) = meas_height;

h = waitbar(0);
for i = 1:length(test_current)
    % for every test current
    params.magnets.I = test_current(i);
    params.levitatingmagnet.I  = -test_current(i); % same current but repelling
    sys = maglevSystem(x0, params, approximationType);
    temp = sys.f([zeros(1,2),meas_height,zeros(1,9)]',zeros(params.solenoids.N,1));
    Fzs(i) = temp(9); %zm_dot should = 0
    waitbar(i/length(test_current),h);
end
close(h)

% search for closest zero Zrs found and store it with his current_pair
% if there's not zero near value it store the minimum found
[~,idx]=min(abs(Fzs-0));
best_curr = test_current(idx);
fprintf("LAST: %f A\n", last_curr);
fprintf("NOW : %f A\n", best_curr);
% save results for next run
if(approximationType == 0)
    results.neo_vs_neo.curr_fst = best_curr;
else
    results.neo_vs_neo.curr_acc = best_curr;
end
save 'results.mat' results

%% Simul system using best_curr at best_height
params.magnets.I = best_curr;
params.levitatingmagnet.I = -best_curr;
x0 = zeros(12,1); x0(3) = meas_height;
sys = maglevSystem(x0, params, approximationType);

Zrs = linspace(min_height,max_height,height_steps);
Fzs = zeros(size(Zrs));
h = waitbar(0);
for i = 1:length(Zrs)
    temp = sys.f([0,0,Zrs(i),zeros(1,9)]',zeros(params.solenoids.N,1));
    Fzs(i) = temp(9);
    waitbar(i/length(Zrs),h);
end
close(h)

%% Plot results
figure(1);
clf; grid minor; hold on;
plot(Zrs,Fzs,"k"); hold on;
xline(meas_height,'r--');
yline(0,'k--'); hold off;
axis([min_height max_height -15 15]);
xlabel('neo vs neo height');
ylabel('repelling force between');

%% Plot selected maglev system
x0 = zeros(12,1); x0(3) = meas_height;
sys = maglevSystem(x0, params, approximationType);
figure(2);
clf; grid on; hold on; daspect([1,1,1]); view([47,15]); axis([-.03 .03 -.03 .03 -.02 meas_height+.02])
draw(sys, 'fancy'); hold off;
title('maglevSystem simulated');

%% Simul and plot evolution of the system
delta = 1E-4; %1 ms
sim_time = .03; % sec
t_ev = 0:delta:sim_time;
z_ev = zeros(1,length(t_ev));
z_ev(1) = min_height + (max_height-min_height)*rand();
x0 = zeros(12,1); x0(3) = z_ev(1);
sys = maglevSystem(x0, params, approximationType);

h = waitbar(0);
for i = 1:length(t_ev)-1
    dx = sys.f([0,0,z_ev(i),zeros(1,9)]',zeros(params.solenoids.N,1));
    dz = dx(9);
    z_ev(i+1) = z_ev(i) + dz * delta;
    waitbar(i/length(t_ev),h);
end
close(h);

figure(3);
clf; grid minor; hold on;
plot(t_ev,z_ev,"k"); hold on;
yline(meas_height,'r--'); hold off;
axis([-10*delta sim_time+10*delta min(z_ev)-.01 max(z_ev)+.01]);
xlabel('t [sec]');
ylabel('levitating neo z(t)');