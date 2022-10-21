%{
    Based on the document 
    "Model Description: Magnetic Levitation System", 
    written by R. Doshmanziari, H.A. Engmark and K.T. Hoang
    available at: https://folk.ntnu.no/hansae/Maglev_System_Description.pdf
%}

classdef maglevSystem < handle
    properties
        m; %mass of the levitating
        
        SOLENOIDS;
        MAGNETS;
        LEVITATINGMAGNET;
        
        % Sensor positions
        xSens;
        ySens;
        zSens;
        
        approximationType;
   end

   methods
        function obj = maglevSystem(x0, params, approximationType)
            mu0 = 4*pi*1e-7;
            obj.approximationType = approximationType;
            
            %% Solenoids
            Xs = params.solenoids.R*cos(linspace(0,2*pi,params.solenoids.N+1));
            Ys = params.solenoids.R*sin(linspace(0,2*pi,params.solenoids.N+1));
            Zs = zeros(size(Xs));

            obj.SOLENOIDS = [solenoid(1,1,1,1,1,1,zeros(12,1),0,0,0,'r')];
            for i = 1:params.solenoids.N
                obj.SOLENOIDS(i) = solenoid(params.solenoids.ri,params.solenoids.ro,params.solenoids.h, ...
                                            params.solenoids.nr,params.solenoids.nh,params.solenoids.nl, ...
                                            [Xs(i),Ys(i),Zs(i)-params.solenoids.h/2 + params.solenoids.zs, 0,0,0,0,0,0,0,0,0]', ...
                                            1,100*mu0,approximationType,'r');
            end
            
            %% Magnets
            Xpm = params.magnets.R*cos(linspace(0,2*pi,params.magnets.N+1)+params.magnets.offset);
            Ypm = params.magnets.R*sin(linspace(0,2*pi,params.magnets.N+1)+params.magnets.offset);
            Zpm = zeros(size(Xpm));

            obj.MAGNETS = [solenoid(1,1,1,1,1,1,zeros(12,1),0,0,0,'r')];
            for i = 1:params.magnets.N
                obj.MAGNETS(i) = solenoid(params.magnets.ri,params.magnets.ro,params.magnets.h, ...
                                          params.magnets.nr,params.magnets.nh,params.magnets.nl, ...
                                          [Xpm(i),Ypm(i),Zpm(i)-params.magnets.h/2,0,0,0,0,0,0,0,0,0]', ...
                                          params.magnets.I,mu0,approximationType,0.5*ones(1,3)); %==gray
            end
            
            %% Floating magnet
            obj.LEVITATINGMAGNET = solenoid(params.levitatingmagnet.ri,params.levitatingmagnet.ro,params.levitatingmagnet.h, ...
                                            params.levitatingmagnet.nr,params.levitatingmagnet.nh,params.levitatingmagnet.nl, ...
                                            x0,params.levitatingmagnet.I,mu0,approximationType,'b');
            obj.m = params.levitatingmagnet.m;
            
            %% Sensors
            obj.xSens = params.sensor.x;
            obj.ySens = params.sensor.y;
            obj.zSens = params.sensor.z;
        end

        function draw(obj,varargin)
            type = 'simple'; % Default
            if nargin > 1
                type = varargin{1};
            end
            
            arrayfun(@(obj) solenoid.draw(obj,type), obj.SOLENOIDS, 'UniformOutput', false); % draw all solenoids
            arrayfun(@(obj) solenoid.draw(obj,type), obj.MAGNETS, 'UniformOutput', false); % draw all magnets
            solenoid.draw(obj.LEVITATINGMAGNET,type); % draw floating magnet
            
            % Draw sensors
            for i = 1:length(obj.xSens)
                plot3(obj.xSens, obj.ySens, obj.zSens, 'k.', 'markersize', 10)
            end
        end

        function B = computeMagneticField(obj,p,u)
            Bs = arrayfun(@(obj) solenoid.magneticField(obj,p(1,:),p(2,:),p(3,:)), obj.SOLENOIDS, 'UniformOutput', false);
            Bs = sum(pagemtimes(reshape([Bs{:}],size(Bs{1},1),size(Bs{1},2),length(Bs)),reshape(u,1,1,length(u))),3);

            Bm = arrayfun(@(obj) solenoid.magneticField(obj,p(1,:),p(2,:),p(3,:)), obj.MAGNETS, 'UniformOutput', false);
            Bm = sum(reshape([Bm{:}],size(Bm{1},1),size(Bm{1},2),length(Bm)),3);
            
            B = Bs + Bm;
        end
        
        function [F,T] = computeMagneticForce(obj,u)
            if obj.approximationType == 0
                p = [obj.LEVITATINGMAGNET.X(:,floor(end/2),floor(end/2)), ...
                     obj.LEVITATINGMAGNET.Y(:,floor(end/2),floor(end/2)), ...
                     obj.LEVITATINGMAGNET.Z(:,floor(end/2),floor(end/2))]';
            else
                p = [obj.LEVITATINGMAGNET.X(:),obj.LEVITATINGMAGNET.Y(:),obj.LEVITATINGMAGNET.Z(:)]';
                
            end
            
            B = computeMagneticField(obj,p,u);
            r = p - obj.LEVITATINGMAGNET.x(1:3);
            l = (circshift(p,-1,2)-circshift(p,1,2));
            %l = l./vecnorm(l).*vecnorm(circshift(p,-1,2)-p); % normalize so the vector has the same length as the line elements
            
            f = obj.LEVITATINGMAGNET.I*cross(l,B);
            t = cross(r,f);
            if obj.approximationType == 0
                F = obj.LEVITATINGMAGNET.nh*obj.LEVITATINGMAGNET.nr*sum(f,2);
                T = obj.LEVITATINGMAGNET.nh*obj.LEVITATINGMAGNET.nr*sum(t,2);
            else
                F = sum(f,2);
                T = sum(t,2);
            end
        end

        function dx = f(obj,x,u)
            % Moment of inertia of a hollow cylinder
            I = obj.m*[
                1/12*(3*(obj.LEVITATINGMAGNET.ri^2+obj.LEVITATINGMAGNET.ro^2)+obj.LEVITATINGMAGNET.h^2);
                1/12*(3*(obj.LEVITATINGMAGNET.ri^2+obj.LEVITATINGMAGNET.ro^2)+obj.LEVITATINGMAGNET.h^2);
                1/2*(obj.LEVITATINGMAGNET.ri^2+obj.LEVITATINGMAGNET.ro^2)];
            g = 9.80665; % gravitational force
            
            if any(obj.LEVITATINGMAGNET.x ~= x)
                obj.LEVITATINGMAGNET.setPosition(x);
            end
            [F,T] = computeMagneticForce(obj,u);
    
            dx = [obj.LEVITATINGMAGNET.x(7:12); zeros(6,1)] + [zeros(6,1); F/obj.m; T./I] + [zeros(8,1); -g; zeros(3,1)];
            dx([6,12]) = [0;0]; % Forces no rotation around z axis
        end

        function y = h(obj,x,u)
            if any(obj.LEVITATINGMAGNET.x ~= x)
                obj.LEVITATINGMAGNET.setPosition(x);
            end
            p = [obj.xSens(:)'; obj.ySens(:)'; obj.zSens(:)'];
            
            Bs = computeMagneticField(obj,p,u);
            Bfm = reshape(solenoid.magneticField(obj.LEVITATINGMAGNET,p(1,:),p(2,:),p(3,:)),3*size(p,2),1);
            Bfs = reshape(Bs,3*size(p,2),1);
            y = 1e4*(Bfm+Bfs);
        end
    end
end