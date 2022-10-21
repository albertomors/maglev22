%{
    1) ...
    2) ...
    3) After modelling the magnet use this trial-and-error tool to find a
    good starting point for the levmag current
    4) ...
    5) ...
%}

clear; close all;
addpath('../maglevFunctions');
load('params.mat');
load('results.mat');
meas_height = results.neo_vs_lev.meas_height;

approximationType = input("approxType [0/1]> ");

%% Searching parameters [EDIT HERE]
min_height = .071;
max_height = .091;
height_steps = 32;

%% Overwrite solenoid parameters
params.solenoids.ri = 0;
params.solenoids.ro = 0; % ...and don't draw it

%% Overwrite neodymium magnets parameters as a single centered one
params.magnets.N = 1; % just one...
params.magnets.R = 0; % ...placed at center
if(approximationType == 0)
    params.magnets.I = results.neo_vs_neo.curr_fst;
else
    params.magnets.I = results.neo_vs_neo.curr_acc;
end

%% Finding the zero point for z graphs with different set currents
Zrs = linspace(min_height,max_height,height_steps); % heights tested
Fzs = zeros(size(Zrs)); % array to store corresponding forces
x0 = zeros(12,1); x0(3) = meas_height;

done = 0;
while(~done)
    test_current = input("current [-1 when happy]> ");
    if(test_current==-1)
        done = 1;
    else
        params.levitatingmagnet.I  = -test_current; % same current but repelling
        sys = maglevSystem(x0, params, approximationType);
        
        h = waitbar(0);
        for i = 1:length(Zrs)
            %simulate system evolution with every height
            temp = sys.f([zeros(1,2),Zrs(i),zeros(1,9)]',zeros(params.solenoids.N,1));
            Fzs(i) = temp(9); %zm_dot should = 0
            waitbar(i/length(Zrs),h);
        end
        close(h);
        
        figure(1);
        grid minor; hold on;
        plot(Zrs,Fzs,"k");
        xline(meas_height,'r--'); yline(0,'k--');
        axis([min_height max_height -15 15]);
        pause(.1);
        xlabel('neo vs levmag height');
        ylabel('repelling force between');
        
        if(approximationType == 0)
            results.neo_vs_lev.curr_fst = test_current;
        else
            results.neo_vs_lev.curr_acc = test_current;
        end
        save 'results.mat' results;
    end
end