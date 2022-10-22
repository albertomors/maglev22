%{
    Author: Alberto Morselli
    Project: maglev22 - https://github.com/albertomors/maglev22
    review of the original code @ https://github.com/martinbronstad/Bachelor_Thesis_E2207

    10.3/(.604s+14) = (10.3/14)/(.604/14+1)
%}

clear; close all;

num = [0 10.3/14];
den = [0.604/14 1];
h = tf(num, den)
step(h);
h0 = dcgain(h);

xline(den(1)); xline(5*den(1))