%{
    Author: Alberto Morselli
    Project: maglev22 - https://github.com/albertomors/maglev22

    shows the total force felt by the levmag moving it through the space
%}

clear; close all;
addpath('../maglevFunctions');
load('params.mat');
load('results.mat');

approximationType = input("approxType [0/1]> ");

%% Searching parameters [EDIT HERE]
steps = 6;
L = .10;

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
Pts = linspace(-L/2,L/2,steps);
Zs = linspace(eq-L*9/10,eq+L*1/10,steps);
Fzs = zeros(length(Pts),length(Pts),length(Zs),3); %3D matrix of a 3-page vals

x0 = zeros(12,1); x0(3) = eq;
sys = maglevSystem(x0, params, approximationType);

h = waitbar(0);
for i = 1:length(Pts) %x
    for j = 1:length(Pts) %y
        for k = 1:length(Zs) %z
            x0(1) = Pts(i); x0(2) = Pts(j); x0(3) = Zs(k);
            temp = sys.f(x0,zeros(params.solenoids.N,1));
            % normalize to make a good plot
            vec = temp(7:9);
            Fzs(i,j,k,:) = vec./(norm(vec)); %x,y,z forces
        end
    end
    waitbar(i/length(Pts))
end
close(h);

%% Plotter
figure(1);
[X,Y,Z] = meshgrid(Pts,Pts,Zs);
[U,V,W] = deal(Fzs(:,:,:,1), Fzs(:,:,:,2), Fzs(:,:,:,3));

idx = Fzs(:,:,:,3) >= 0;
quiver3(X(idx),Y(idx),Z(idx), U(idx),V(idx),W(idx), .6, 'r'); hold on;
quiver3(X(~idx),Y(~idx),Z(~idx), U(~idx),V(~idx),W(~idx), .6, 'b'); hold on;
grid on; axis equal; view([45,15]);
xlabel('x'); ylabel('y'); zlabel('z');

x0 = zeros(12,1); x0(3) = eq;
sys = maglevSystem(x0, params, approximationType);
draw(sys, 'fancy'); hold off;