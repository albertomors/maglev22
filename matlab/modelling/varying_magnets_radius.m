%{
    Author: Alberto Morselli
    Project: maglev22 - https://github.com/albertomors/maglev22
    review of the original code @ https://github.com/martinbronstad/Bachelor_Thesis_E2207
    
    shows the force felt by the levmag at different heights [searching the
    one that is an equilibrium Fz=0] at permanent magnet radius mounting setup
%}

clear; close all;
addpath('../maglevFunctions');
load('params.mat');
load('results.mat');

approximationType = input("approxType [0/1]> ");

%% Searching parameters [EDIT HERE]
min_height = .03;
max_height = .10;
height_steps = 128;

minR = .01;
maxR = .05;
Rsteps = 16;

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

%% Force 3D plot
Rs = linspace(minR,maxR,Rsteps);
Zrs = linspace(min_height,max_height,height_steps);
Fzs = zeros(length(Rs), length(Zrs));

h = waitbar(0);
for i = 1:length(Rs) %row
    params.magnets.R = Rs(i);
    sys = maglevSystem(x0, params, approximationType);
    
    for j = 1:length(Zrs) %column
        temp = sys.f([0,0,Zrs(j),zeros(1,9)]',zeros(params.solenoids.N,1));
        Fzs(i,j) = temp(9);
    end
    waitbar(i/length(Rs))
end
close(h);

%% Plotter
figure(1);
surf(Zrs, Rs, Fzs); hold on
surf(Zrs, Rs, zeros(length(Rs),length(Zrs)),'FaceColor', 'k', 'EdgeColor','none','FaceAlpha',.5);
axis([min_height max_height minR maxR -30 30]); hold off; 
xlabel('Levitating height');
ylabel('Permanent magnet radius');