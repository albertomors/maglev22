%{
    show the controllability zone of the system with solenoids running 
    at max power of 0.5A
%}

clear; close all;
addpath('../maglevFunctions');
load('params.mat');
load('results.mat');

approximationType = input("approxType [0/1]> ");

%% Searching parameters [EDIT HERE]
eqR = .05;
Hsteps = 512;
maxR = .1;
Rsteps = 512;

% load correct parameters
if(approximationType == 0)
    eq = results.zeq.zeq_fst;
    params.magnets.I = results.neo_vs_neo.curr_fst;
    params.levitatingmagnet.I = results.neo_vs_lev.curr_fst;
else
    eq = results.zeq.zeq_acc;
    params.magnets.I = results.neo_vs_neo.curr_acc;
    params.levitatingmagnet.I = results.neo_vs_lev.curr_acc;
end

%% Derived parameters
% Doubles the space for two halfs respectively for positive error
% (solenoids = +-) and for negative (solenoids = -+)
Xs = linspace(-maxR,maxR,2*Rsteps);
Ys = Xs;
Zs = linspace(eq-eqR,eq+eqR,2*Hsteps);

Fxs = zeros(1,length(Xs));
Fys = Fxs;
Fzs = zeros(1,length(Zs));

%% Start searching
% reset for calcs on X-axis
x0 = zeros(12,1); x0(3) = eq;
sys = maglevSystem(x0, params, approximationType);

for i = 1:length(Xs)
    x0(1) = Xs(i);
    temp = sys.f(x0,[.5 0 -.5 0]');
                    %x1 y1 x2 y2
                    %xpos ypos xneg yneg
    Fxs(i) = temp(7);
end

% reset for calcs on Y-axis
x0 = zeros(12,1); x0(3) = eq;
sys = maglevSystem(x0, params, approximationType);

for i = 1:length(Ys)
    x0(2) = Ys(i);
    temp = sys.f(x0,[0 .5 0 -.5]');
    Fys(i) = temp(8);
end

% reset for calcs on Z-axis
x0 = zeros(12,1); x0(3) = eq;
sys = maglevSystem(x0, params, approximationType);

for i = 1:length(Zs)/2
    x0(3) = Zs(i);
    temp = sys.f(x0,[.5 .5 .5 .5]');
    Fzs(i) = temp(9);
end
for i = length(Zs)/2+1:length(Zs)
    x0(3) = Zs(i);
    temp = sys.f(x0,[-.5 -.5 -.5 -.5]');
    Fzs(i) = temp(9);
end

% X-Y controllability
figure(1);
plot3(Xs,zeros(1,length(Xs)),Fxs); hold on;
plot3(zeros(1,length(Ys)),Ys,Fys);
xlabel('X'); ylabel('Y'); zlabel('Fx/Fy')
grid minor; xline(0); yline(0);

%Find 0-near values for both x and y planes
idxs = zeros(1,4);
[~,idxs(1)] = min(abs(Fxs(1:end/2)));
[~,idxs(2)] = min(abs(Fxs(end/2+1:end))); idxs(2) = idxs(2) + length(Fxs)/2;
[~,idxs(3)] = min(abs(Fys(1:end/2)));
[~,idxs(4)] = min(abs(Fys(end/2+1:end))); idxs(4) = idxs(4) + length(Fys)/2;

% plot circles on 0-values
plot3(Xs(idxs(1:2)),0,0,'ko');
plot3(0,Ys(idxs(3:4)),0,'ko');

% plot X-Y plane of controllability
[X,Y] = meshgrid(Xs(idxs(1:2)),Ys(idxs(3:4)));
Z = zeros(length(X));
surf(X,Y,Z); hold off;

%% Z-controllability
figure(2);
plot(Zs,Fzs); hold on;
xlabel('Z'); ylabel('Fz')
grid minor; yline(0);

% find 0-near values
idxs_2 = zeros(1,2);
[~,idxs_2(1)] = min(abs(Fzs(1:end/2)));
[~,idxs_2(2)] = min(abs(Fzs(end/2+1:end))); idxs_2(2) = idxs_2(2) + length(Fzs)/2;

% plot circles on 0-values
Z = Zs(idxs_2(1:2));
plot(Z,0,'ko');

% plot Z zone of controllability
plot(Zs(idxs_2),[0,0],'LineWidth',2); hold off;

%% maglevSystem controllability zone plotter
figure(3);
x0 = zeros(12,1); x0(3) = eq;
sys = maglevSystem(x0, params, approximationType); 
hold on; draw(sys, 'fancy'); grid on; axis equal; view([45,30]);

% plot 3D cube-zone
[x1, x2] = deal(Xs(idxs(1)),Xs(idxs(2)));
[y1, y2] = deal(Ys(idxs(3)),Ys(idxs(4)));
[z1, z2] = deal(Zs(idxs_2(1)),Zs(idxs_2(2)));

xl = x2-x1; yl = y2-y1; zl = z2-z1;

plotcube([xl yl zl], [x1 y1 z1], .1, [1,0,0]); hold off;