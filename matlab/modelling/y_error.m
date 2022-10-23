%{
    Author: Alberto Morselli
    Project: maglev22 - https://github.com/albertomors/maglev22

    simulates y output of the system (with u=0) with a virtual sensor on the center (0,0,0)
    and with the 5 configuration and compares result while moving the levmag
    across a random path
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
points = 64;
L = .02; %double it to obtain the cube side surrounding the path

x0 = zeros(12,1); x0(3) = eq;
params.sensor.z(5) = params.sensor.z(4);
sys = maglevSystem(x0, params, approximationType);
yeq = sys.h(x0,zeros(params.solenoids.N,1));

%override params.sensor
params2 = params;
params2.sensor.z = params.sensor.z(1); %same height as the real sensors...
params2.sensor.x = 0;
params2.sensor.y = 0; % ...but centered

sys2 = maglevSystem(x0, params2, approximationType);
yeq2 = sys2.h(x0,zeros(params2.solenoids.N,1));

%% 5
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

%virtual
bxx_eq = yeq2(1);
byy_eq = yeq2(2);
bzz_eq = yeq2(3);

%create path
t = linspace(0,2*pi,points);
px = L*cos(t);
py = 0.5*L*sin(t);
pz = eq + (2*L/30.*t./2*pi - L/30);

bx1 = zeros(1,points);
bx2 = bx1; by1=bx1; by2=bx1; bz=bx1; %5
bxx = bx1; byy=bx1; bzz=bx1; %virtual

%%

for i=1:points
    x0(1) = px(i); x0(2) = py(i); x0(3) = pz(i);
    temp = sys.h(x0,zeros(params.solenoids.N,1));
    temp2 = sys2.h(x0,zeros(params2.solenoids.N,1));
    %sys.h is a 5x3=15 values-variable that stores Bx,By,Bz for every of
    %the 5 sensors. In the real-life x-sensor can estimate only Bx, y only By and
    %z only Bz. We proceed to trash the other values

    % 5
    bx1(i) = temp(1);
    bx2(i) = temp(4);
    by1(i) = temp(8);
    by2(i) = temp(11);
    bz(i) = temp(15);

    %virtual sensor
    bxx(i) = temp2(1);
    byy(i) = temp2(2);
    bzz(i) = temp2(3);
end

%%

dbx1 = bx1-bx1_eq;
dby1 = by1-by1_eq;
dbx2 = bx2-bx2_eq;
dby2 = by2-by2_eq;
dbz = bz-bz_eq;

%5
dbx = (dbx1+dbx2)/2;
dby = (dby1+dby2)/2;

%virtual
dbxx = bxx-bxx_eq;
dbyy = byy-byy_eq;
dbzz = bzz-bzz_eq;

figure(1);
subplot(221);
plot(t,dbx1,t,dbx2); hold on;
plot(t,dbx,'LineWidth',2);
plot(t,dbxx,"--",'LineWidth',1)
legend("x1","x2","<x>","X");
yline(0);

subplot(222);
plot(t,dby1,t,dby2,'LineWidth',1); hold on;
plot(t,dby,'LineWidth',2);
plot(t,dbyy,"--",'LineWidth',1)
legend("y1","y2","<y>","Y");
yline(0);

subplot(223);
plot(t,dbz,'LineWidth',2); hold on;
plot(t,dbzz,"--",'LineWidth',1);
legend("z","Z");
yline(0);

ex = (dbx-dbxx)./max(abs(dbxx))*100;
ey = (dby-dbyy)./max(abs(dbyy))*100;
ez = (dbz-dbzz)./max(abs(dbzz))*100;

subplot(224);
plot(t,ex,t,ey,t,ez,'LineWidth',2); hold on;
legend("ex","ey","ez");
yline(0);