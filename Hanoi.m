classdef Hanoi < handle
% This class defines the functions necessary to generate action models in
% the 3-peg Hanoi domain. The numer of rings can be specified as a
% parameter to the constructor of the class.
    properties
        nConfigurations; % The number of states in the MDP, 
                         % except the sink state.
        n; % The number of disks.
    end
    
    methods
        function obj = Hanoi(n)
        % The constructor takes the number of disks as the only argument.
            obj.nConfigurations = 3^n;
            obj.n = n;
        end
        
        function As = generateActions(obj,isDeterministic)
        % This function generates the action models. There are 3 actions.
        % The first two actions move the smallest disk to one of the other
        % pegs. The thord action moves the top disk between the two pegs 
        % that do not have the smallest disk.
             As{1,1} = obj.generateAction(@obj.moveSmall1OfIndex,...
                                            isDeterministic);
             As{2,1} = obj.generateAction(@obj.moveSmall2OfIndex,...
                                            isDeterministic);
             As{3,1} = obj.generateAction(@obj.moveOfIndex,...
                                            isDeterministic);
             As = cellfun(@packModel,As,'UniformOutput',false);
        end
        
        function A = generateAction(obj, moveFun, isDeterministic)
        % This function generates the action model for an action. The
        % moveFun paramter is meant to map the index of the source state to
        % the index of the destination state. The isDeterministic paramter
        % distinguishes between the deterministic and non-deterministic
        % version of the problem.
            P = sparse(obj.nConfigurations + 1,obj.nConfigurations + 1);
            P(obj.nConfigurations + 1,obj.nConfigurations + 1) = 1;
            finalIndex = obj.permToIndex(3*ones(1,obj.n));
            
            P(finalIndex, obj.nConfigurations + 1) = 1;
            
            R = ones(obj.nConfigurations + 1,1) * -1;
            
            R(obj.nConfigurations + 1) = 0;
            R(finalIndex) = 10000;
            
            for i=1:obj.nConfigurations
                if i ~= finalIndex
                    if isDeterministic
                        P(i,moveFun(i)) = 1;
                    else
                        P(i,moveFun(i)) = 0.95;
                        P(i,i) = 0.05;
                    end
                end
            end            
            
            A.P = P;
            A.R = R;
        end
        
        function i = permToIndex(obj,p)
        % This function maps the tuple representation of a state to a state
        % index. We treat the tuple as a number written in base-3 and
        % compute the value of the number.
            i = 1;
            for j=obj.n:-1:1
                i = i + (p(j) - 1) * 3^(obj.n - j);
            end
        end
        
        function p = indexToPerm(obj,i)
        % This function maps the index representation of a state to a 
        % tuple. We treat the tuple as a number written in base-3 and
        % compute the value of the number.

            p = zeros(1,obj.n);
            for j=obj.n:-1:1
                p(j) = 1 + floor(mod(i-1,3^(obj.n - j + 1)) / 3^(obj.n - j));
            end
        end             
        
        % The three functions below generate the moves in the Hanoi domain.
        % They work on the index representation of state, i.e. they map 
        % index to index. 
        
        function i2 = moveSmall1OfIndex(obj,i)
            i2 = obj.permToIndex(obj.moveSmall1(obj.indexToPerm(i)));
        end
        
        function i2 = moveSmall2OfIndex(obj,i)
            i2 = obj.permToIndex(obj.moveSmall2(obj.indexToPerm(i)));
        end
        
        function i2 = moveOfIndex(obj,i)
            i2 = obj.permToIndex(obj.move(obj.indexToPerm(i)));
        end
                                
        % The three functions below generate the moves in the hanoi domain.
        % They work on the tuple representation of state, i.e. the i-th
        % element of the tuple vector is a value from the set {1,2,3} and
        % determines the peg where the i-th disk is on.
        
        function p = moveSmall1(obj,p)
        % Move smallest disk to one of the other pegs.
            p(1) = mod(p(1),3) + 1;
        end
               
        function p = moveSmall2(obj,p)
        % Move smallest disk to one of the other pegs.
            p(1) = mod(p(1) + 1,3) + 1;
        end
                
        function p = move(obj,p)
        % Move disk between the other two pegs.
            c = zeros(1,2);
            c(1) = mod(p(1),3) + 1;
            c(2) = mod(p(1) + 1,3) + 1;                        
                                    
            f1 = sort(find(p == c(1)));
            f2 = sort(find(p == c(2)));
            
            if isempty(f1) && isempty(f2)
                return;
            elseif ~isempty(f2) && (isempty(f1) || f2(1) < f1(1))
                p(f2(1)) = c(1);
            else
                p(f1(1)) = c(2);
            end                                    
        end
        
    end
    
end
