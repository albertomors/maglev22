%{
    10.3/(.604s+14) = (10.3/14)/(.604/14+1)
%}

clear; close all;

num = [0 10.3/14];
den = [0.604/14 1];
h = tf(num, den)
step(h);
h0 = dcgain(h);

yline(.67*h0); yline(.99*h0)
xline(den(1)); xline(5*den(1))

n = 1e5;
ts = 62e-6; %runtime of every loop of the teensy
t = 0:ts:(n-1)*ts;
u = zeros(1,n);

u(1) = rand(); %value from 0 to 1 of the voltage applied [like pwm]
for i=2:n
    du = (rand()-.5)*.001; % 0.1% maximum change of the power applied
    u(i) = u(i-1)+du;
end

figure(2);
lsim(h,u,t);
