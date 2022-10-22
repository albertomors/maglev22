%{
    Author: Alberto Morselli
    Project: maglev22 - https://github.com/albertomors/maglev22

    simulates y output of the system (with u=0) and move the levmag
    across a decided path to check if the sensors estimation ability
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

%% EDIT PARAMS
steps = 300; %divisible by 6
L = .02; %double it to obtain the cube side surrounding the path

x0 = zeros(12,1); x0(3) = eq;
sys = maglevSystem(x0, params, approximationType);
yeq = sys.h(x0,zeros(params.solenoids.N,1));

bx1_eq = yeq(1); %x1_x
                 %x1_y
                 %x1_z

bx2_eq = yeq(4); %x2_x
                 %
                 %

                 %
by1_eq = yeq(8); %y1_y
                 %

                 %
by2_eq = yeq(11);%y2_y
                 %

                 %
                 %
bz_eq = yeq(15); %z_z

px = linspace(-L,L,steps);
py = zeros(1,steps);
pz = eq*ones(1,steps);

bx1 = zeros(1,steps);
bx2 = bx1; by1=bx1; by2=bx1; bz=bx1;

x0 = zeros(12,1); x0(3) = eq;
sys = maglevSystem(x0, params, approximationType);

for i=1:steps
    x0(1) = px(i);
    temp = sys.h(x0,zeros(params.solenoids.N,1));
    %sys.h is a 5x3=15 values-variable that stores Bx,By,Bz for every of
    %the 5 sensors. In the real-life x-sensor can estimate only Bx, y only By and
    %z only Bz. We proceed to trash the other values
    bx1(i) = temp(1);
    bx2(i) = temp(4);
    by1(i) = temp(8);
    by2(i) = temp(11);
    bz(i) = temp(15);
end

dbx1 = bx1-bx1_eq;
dby1 = by1-by1_eq;
dbx2 = bx2-bx2_eq;
dby2 = by2-by2_eq;
dbz = bz-bz_eq;

figure(1);
subplot(221);
plot3(px,py,pz); hold on;
plot3(px(1), py(1), pz(1), 'o');
plot3(px(end), py(end), pz(end), '^');
draw(sys,'fancy'); hold off;
xlabel('x'); ylabel('y'); zlabel('z');

subplot(222);
plot(px,dbx1,px,dbx2); hold on;
title('x1,x2 on movement along x');
xline(0); yline(0);

[mx1,idm1] = min(dbx1);
[Mx1,idM1] = max(dbx1);
[mx2,idm2] = min(dbx2);
[Mx2,idM2] = max(dbx2);

plot([px(idm1) px(idM1) px(idm2) px(idM2)], [mx1 Mx1 mx2 Mx2], 'o');
legend("x1","x2"); hold off;

subplot(223);
plot(px,dby1,px,dby2); hold on;
title('y1,y2 on movement along x');
xline(0); yline(0); hold off;

subplot(224)
plot(px,dbz); hold on;
title('z on movement along x');
xline(0); yline(0);

%% free track
px = [L*ones(1,steps/2), linspace(L,-L,steps/2)];
py = [linspace(-L,L,steps/2), L*ones(1,steps/2)];
pz = eq + [50*L^2-50*py(1:steps/2).^2, zeros(1,steps/2)];

bx1 = zeros(1,steps);
bx2 = bx1; by1=bx1; by2=bx1; bz=bx1;

x0 = zeros(12,1); x0(3) = eq;
sys = maglevSystem(x0, params, approximationType);

for i=1:steps
    x0(1:3) = [px(i),py(i),pz(i)];
    temp = sys.h(x0,zeros(params.solenoids.N,1));
    %sys.h is a 5x3=15 values-variable that stores Bx,By,Bz for every of
    %the 5 sensors. In the real-life x-sensor can estimate only Bx, y only By and
    %z only Bz. We proceed to trash the other values
    bx1(i) = temp(1);
    bx2(i) = temp(4);
    by1(i) = temp(8);
    by2(i) = temp(11);
    bz(i) = temp(15);
end

dbx1 = bx1-bx1_eq;
dby1 = by1-by1_eq;
dbx2 = bx2-bx2_eq;
dby2 = by2-by2_eq;
dbz = bz-bz_eq;

figure(2);
subplot(221);
params.levitatingmagnet.ro = 0;
sys = maglevSystem(x0, params, approximationType);
plot3(px,py,pz); hold on;
plot3(px(1), py(1), pz(1), 'o');
plot3(px(end), py(end), pz(end), '^');
draw(sys,'fancy'); hold off;
xlabel('x'); ylabel('y'); zlabel('z');
daspect([1,1,1]); zlim([-0.02 0.1])
grid on

t = linspace(1,steps,steps);

subplot(222);
plot(t,dbx1,t,dbx2); hold on;
title('x1,x2 readings');
xline(0); yline(0); hold off;
grid on

subplot(223);
plot(t,dby1,t,dby2); hold on;
title('y1,y2 readings');
xline(0); yline(0); hold off;
grid on

subplot(224)
plot(t,dbz); hold on;
title('z readings');
xline(0); yline(0); hold off;
grid on