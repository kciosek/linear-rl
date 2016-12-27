classdef HanoiFeatures < handle
% This class is reponsible for generating the aggregation matrix and the
% subgoal values for the towers of Hanoi Problem. The aggregation framework
% is set up so that, for a subproblem of size m, we ignore all disks except
% the m smallest disks.
    
    % See the constructor for definitions of properties.
    properties
        smallHanoi;
        bigHanoi;
        Gval = subgoalVal();
    end
    
    methods
        function Phi = generatePhi(obj)
        % This function generates the aggregation matrix. 
            Phi = sparse(obj.bigHanoi.nConfigurations + 1, ...
                         obj.smallHanoi.nConfigurations + 1);
                     
            for ib = 1:obj.bigHanoi.nConfigurations
                p = obj.bigHanoi.indexToPerm(ib);
                % Ignore all disks with index greater than obj.smallHanoi.n
                sp = p(1:obj.smallHanoi.n);
                is = obj.smallHanoi.permToIndex(sp);
                Phi(ib,is) = 1;
            end
            
            Phi(obj.bigHanoi.nConfigurations + 1, ...
                obj.smallHanoi.nConfigurations + 1) = 1;
        end
                
        function G = generateG(obj,peg)
        % Generate the subgoal vector for placing all the disks on peg
        % given by the parameter peg (1-3).
            G = zeros(obj.smallHanoi.nConfigurations + 1, 1);
            gi = obj.smallHanoi.permToIndex(...
                ones(1,obj.smallHanoi.n) * peg);
            G(gi) = obj.Gval;
        end
        
        function obj = HanoiFeatures(m,bigHanoi)
        % Construct the object used to generate the approximation
        % architecture for the Hanoi domain. The bigHanoi parameter
        % specifies the original problem that we arre approximating. The m
        % paramter specifies how many disks the present approximation uses.
            obj.bigHanoi = bigHanoi;
            obj.smallHanoi = Hanoi(m);
        end
    end
    
end

