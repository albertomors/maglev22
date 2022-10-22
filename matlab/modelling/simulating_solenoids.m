%{
    Author: Alberto Morselli
    Project: maglev22 - https://github.com/albertomors/maglev22

    simulate the system evolution setting the solenoids in a certain way
%}

clear; close all;
addpath('../maglevFunctions');
load('params.mat');
load('results.mat');

approximationType = 0;

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

%% Start simulating

%Here set different initial conditions to test solenoids action
x0 = zeros(12,1); x0(3) = eq;
dt = 1e-3;
sys = maglevSystem(x0, params, approximationType);

while 1
    sys = maglevSystem(x0, params, approximationType);
    
    %And here set solenoids and see how the levmag evolves
    dx = sys.f(x0,[.5 0 -.5 0]');
                  %x1 y1 x2 y2
    x0 = x0 + dx*dt;
    hold on; draw(sys, 'simple'); axis equal; view(3);
    xlabel('x'); ylabel('y');
    pause()
end

%%
sys = maglevSystem(x0, params, approximationType);
params.levitatingmagnet.ro = 0;
draw(sys, 'fancy'); axis equal; view(3);