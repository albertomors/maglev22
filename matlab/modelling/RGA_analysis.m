%{
    Author: Alberto Morselli
    Project: maglev22 - https://github.com/albertomors/maglev22
    review of the original code @ https://github.com/martinbronstad/Bachelor_Thesis_E2207

    Linearizes the magnetic levitation system and calculates the condition
    number and Relative Gain Array (RGA)
%}

clear; close all;
addpath('../maglevFunctions');
load('params.mat');
load('results.mat');

approximationType = input("approxType [0/1]> ");

if(approximationType == 0)
    eq = results.zeq.zeq_fst;
    params.magnets.I = results.neo_vs_neo.curr_fst;
    params.levitatingmagnet.I = results.neo_vs_lev.curr_fst;
else
    eq = results.zeq.zeq_acc;
    params.magnets.I = results.neo_vs_neo.curr_acc;
    params.levitatingmagnet.I = results.neo_vs_lev.curr_acc;
end

%% Linearization of system
x0 = zeros(12,1); x0(3) = eq;
sys = maglevSystem(x0, params, approximationType);

uLp = zeros(params.solenoids.N,1); % inputs
xLp = zeros(12,1); xLp(3) = eq; % equilibrium point around which to linearize the system

delta = 1e-4;
dimX = 12;
dimU = params.solenoids.N; % 4
dimY = 3*length(params.sensor.x); % 3x5=15

h = waitbar(0);
max = dimX+dimU+dimX;

% d(x/dx) empty matrix of dimension x*x (12x12) where
% on rows there's df(i=1:12)/.
% on columns there's ./dx(i=1:12)
A = zeros(dimX,dimX);
for i = 1:dimX % for every column
    % linearize the entire column
    A(:,i) = (sys.f(xLp+(i==1:dimX)'*delta,uLp) ...
             -sys.f(xLp-(i==1:dimX)'*delta,uLp)) ...
             /(2*delta);
    waitbar(i/max);
end

% d(x/du) empty matrix of dimension x*u (12x4)
B = zeros(dimX,dimU);  
for i = 1:dimU
    B(:,i) = (sys.f(xLp,uLp+(i==1:dimU)'*delta) ...
             -sys.f(xLp,uLp-(i==1:dimU)'*delta)) ...
             /(2*delta);
    waitbar((i+dimX)/max);
end

% d(y/dx) empty matrix of dimension y*x (15x12)
C = zeros(dimY,dimX);
for i = 1:dimX
    C(:,i) = (sys.h(xLp+(i==1:dimX)'*delta, uLp) ...
             -sys.h(xLp-(i==1:dimX)'*delta, uLp)) ...
             /(2*delta);
    waitbar((i+dimX+dimU)/max);
end
close(h);

% d(y/du) = 0
D = zeros(dimY, dimU);

%% State space to transfer function
ssModel = ss(A,B,C,D);  % State-space model
G = tf(ssModel);  % Creating a transfer matrix

% the tf is now a map from u(4x1) to u(15x1 aka 5x3)
% now the y2 value is computed by y with a mean in this way:
%
% get x = (x1 + x2)/2
%     y = (y1 + y2)/2
%     z = z
%
% x1 x2 y1 y2 z are in array position 1 4 8 11 15
%
% so x = 1 + 4
%    y = 8 + 11
%    z = z
%
% so we need a matrix to make y2 = M*y = M*G*u
%
%    1     4       8     11      15
M = [1 0 0 1 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 1 0 0 1 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]./[2; 2; 1];

G1 = M*G;

save 'ss_matrices.mat' A B C D G G1

%% Solenoids control tf
% now G1 is a map from u(4x1) to y2(3x1)
% we want to make a map from (ux,uy,yz) -> u -> y2
%                                       Hc   G1
%
% Hc has to transform (ux,uy,uz) = 3x1 to u = (4x1)
% in this way:
%
% coil x1 = u(1) = +ux; coil x2 = u(3) = -ux;
% coil y1 = u(2) = +uy; coil y2 = u(4) = -uy;
%
% Hc maps ux,uy,uz [0:255 pwm value] to u[-0.5:+0.5] current
% so theres a constant gain = 0.5/255

Hc = 0.5/255 .* [1  0  1;
                 0  1  1;
                -1  0  1;
                 0 -1  1];

% final tf from (ux,uy,uz)' to y2
H = G1*Hc; % transfer matrix of the chosen control strategy

save 'ss_matrices.mat' Hc H -append

%% Condition number and RGA
H0 = dcgain(H);         % Static gain array
gamma = cond(H0);       % Condition number
LAMBDA = H0.*inv(H0);   % RGA