%{
    Based on the document 
    "Model Description: Magnetic Levitation System", 
    written by R. Doshmanziari, H.A. Engmark and K.T. Hoang
    available at: https://folk.ntnu.no/hansae/Maglev_System_Description.pdf
%}

classdef solenoid < handle
    properties
        %% User defined
        ri; % inner radius
        ro; % outer radius
        h;

        nr; % radius steps
        nh; % height steps
        nl; % segment steps

        x; % position and rotation of center in reference frame
        I; % current in solenoid
        mu0; % permeability of air
        approximationType; % 0 for "fast" / 1 for "accurate"
        
        %% Derived parameters
        % Rings in cylindrical coordinates (local frame)
        RHOs;
        PHIs;
        Zs;
        
        % Rings in cartesian coordinates (local frame)
        Xs;
        Ys;
        %Zs; (already defined)
        
        % Rings in cylindrical coordinates (global frame)
        %RHO;
        %PHI;
        %Z;
        
        % Rings in cartesian coordiantes (global frame)
        X;
        Y;
        Z;
        
        Mt; % translation matrix
        Mr; % rotation matrix
        
        c; % color
    end

    methods
        function obj = solenoid(ri,ro,h,nr,nh,nl,x,I,mu0,approximationType,c)
            obj.ri = ri;
            obj.ro = ro;
            obj.h = h;
            obj.nr = nr;
            obj.nh = nh;
            obj.nl = nl;
            obj.x = x;
            obj.I = I;
            obj.mu0 = mu0;
            obj.approximationType = approximationType;
            
            obj.c = c;
            [obj.RHOs,obj.PHIs,obj.Zs] = meshgrid(linspace(ri,ro,nr), linspace(0,2*pi-2*pi/nl,nl),linspace(-h/2,h/2,nh));
            [obj.Xs,obj.Ys,obj.Zs] = pol2cart(obj.PHIs,obj.RHOs,obj.Zs);
            
            obj.Mt = translationMatrix(x(1),x(2),x(3));
            %obj.Mr = rotationMatrix(x(4),x(5),x(6));
            obj.Mr = rotationMatrix2(x(4),x(5));
            
            obj.X = obj.Mr(1,1)*obj.Xs+obj.Mr(1,2)*obj.Ys+obj.Mr(1,3)*obj.Zs+obj.Mt(1,4);
            obj.Y = obj.Mr(2,1)*obj.Xs+obj.Mr(2,2)*obj.Ys+obj.Mr(2,3)*obj.Zs+obj.Mt(2,4);
            obj.Z = obj.Mr(3,1)*obj.Xs+obj.Mr(3,2)*obj.Ys+obj.Mr(3,3)*obj.Zs+obj.Mt(3,4);
        end
        
        function setPosition(obj,x)
            obj.x = x;
            
            obj.Mt = translationMatrix(x(1),x(2),x(3));
            %obj.Mr = rotationMatrix2(x(4),x(5),x(6));
            obj.Mr = rotationMatrix2(x(4),x(5));

            obj.X = obj.Mr(1,1)*obj.Xs+obj.Mr(1,2)*obj.Ys+obj.Mr(1,3)*obj.Zs+obj.Mt(1,4);
            obj.Y = obj.Mr(2,1)*obj.Xs+obj.Mr(2,2)*obj.Ys+obj.Mr(2,3)*obj.Zs+obj.Mt(2,4);
            obj.Z = obj.Mr(3,1)*obj.Xs+obj.Mr(3,2)*obj.Ys+obj.Mr(3,3)*obj.Zs+obj.Mt(3,4);
        end
    end

    methods(Static)
        function h = draw(obj,varargin)
            type = 'simple'; % Default
            if nargin > 1
                type = varargin{1};
            end

            Xp = obj.X; Xp(end+1,:,:) = Xp(1,:,:);
            Yp = obj.Y; Yp(end+1,:,:) = Yp(1,:,:);
            Zp = obj.Z; Zp(end+1,:,:) = Zp(1,:,:);
            
            switch type
                case 'fancy'
                    alpha = 0.9;
                    
                    h1 = surf(reshape(Xp(:,1,[1,end]),obj.nl+1,2)',reshape(Yp(:,1,[1,end]),obj.nl+1,2)',reshape(Zp(:,1,[1,end]),obj.nl+1,2)', 'facecolor', obj.c,'edgecolor','none','facealpha',alpha);
                    h2 = surf(reshape(Xp(:,end,[1,end]),obj.nl+1,2)',reshape(Yp(:,end,[1,end]),obj.nl+1,2)',reshape(Zp(:,end,[1,end]),obj.nl+1,2)', 'facecolor', obj.c,'edgecolor','none','facealpha',alpha);
                    h3 = fill3(reshape(Xp(:,[1,end],1),2*obj.nl+2,1),reshape(Yp(:,[1,end],1),2*obj.nl+2,1),reshape(Zp(:,[1,end],1),2*obj.nl+2,1),obj.c,'facealpha',alpha);
                    h4 = fill3(reshape(Xp(:,[1,end],end),2*obj.nl+2,1),reshape(Yp(:,[1,end],end),2*obj.nl+2,1),reshape(Zp(:,[1,end],end),2*obj.nl+2,1),obj.c,'facealpha',alpha);
                    h = [h1,h2,h3,h4];
                case 'simple'
                    if obj.approximationType
                        h = line(Xp(:),Yp(:),Zp(:),'color',obj.c);
                    else
                        h = line(Xp(:,floor(end/2),floor(end/2)),Yp(:,floor(end/2),floor(end/2)),Zp(:,floor(end/2),floor(end/2)),'color',obj.c);
                    end
                otherwise 
                    if obj.approximationType
                        h = line(Xp(:),Yp(:),Zp(:));
                    else
                        h = line(Xp(:,end/2,end/2),Yp(:,end/2,end/2),Zp(:,end/2,end/2));
                    end
            end
        end
           
        function B = magneticField(obj,xk,yk,zk)
            if obj.approximationType == 0             
                % Only one ring
                rhos = obj.RHOs(1,floor(end/2),floor(end/2));
                zs = obj.Zs(1,floor(end/2),floor(end/2));
            else
                % Full
                rhos = reshape(obj.RHOs(1,:,:),obj.nr*obj.nh,1);
                zs = reshape(obj.Zs(1,:,:),obj.nr*obj.nh,1);
            end

            xks = obj.Mr(1,1)*xk+obj.Mr(2,1)*yk+obj.Mr(3,1)*zk-obj.Mt(1,4);
            yks = obj.Mr(1,2)*xk+obj.Mr(2,2)*yk+obj.Mr(3,2)*zk-obj.Mt(2,4);
            zks = obj.Mr(1,3)*xk+obj.Mr(2,3)*yk+obj.Mr(3,3)*zk-obj.Mt(3,4);

            % Compute magnetic field
            [phi,rho,z] = cart2pol(xks,yks,zks);
            
            % Constrain val between 0 and 1 as computing imprecision can
            % cause val to go over 1 (like 1.0003)
            val = (4*rhos*rho)./((rhos+rho).^2+(z-zs).^2);
            val = max(0, val); val = min(val, 1);

            [K,E] = ellipke(val);
            bphi = repmat(phi,length(zs),1);
            brho = obj.I*obj.mu0./(2*pi*sqrt((rhos+rho).^2+(z-zs).^2)).*(((z-zs)./rho).*(((rhos.^2+rho.^2+(z-zs).^2)./((rho-rhos).^2+(z-zs).^2)).*E - K));
            bz = -obj.I*obj.mu0./(2*pi*sqrt((rhos+rho).^2+(z-zs).^2)).*(((rho.^2-rhos.^2+(z-zs).^2)./((rho-rhos).^2+(z-zs).^2)).*E - K);

            % Limit Expression for rho=0
            idRho0 = find(rho == 0);
            if ~isempty(idRho0)
               bphi(:,idRho0) = 0;
               brho(:,idRho0) = 0;
               bz(:,idRho0) = obj.mu0*rhos.^2*obj.I./(2*(rhos.^2+(z(idRho0)-zs).^2).^(3/2));
            end

            [bxs,bys,bzs] = pol2cart(bphi,brho,bz);

            bx = obj.Mr(1,1)*sum(bxs,1)+obj.Mr(1,2)*sum(bys,1)+obj.Mr(1,3)*sum(bzs,1);
            by = obj.Mr(2,1)*sum(bxs,1)+obj.Mr(2,2)*sum(bys,1)+obj.Mr(2,3)*sum(bzs,1);
            bz = obj.Mr(3,1)*sum(bxs,1)+obj.Mr(3,2)*sum(bys,1)+obj.Mr(3,3)*sum(bzs,1);
            
            if obj.approximationType == 0
                B = obj.nh*obj.nr*[bx;by;bz];
            else
                B = [bx;by;bz];
            end
        end
    end    
end 