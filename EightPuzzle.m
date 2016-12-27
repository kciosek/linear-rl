classdef EightPuzzle < handle
% This class defines the functions necessary to implement the 8-puzzle
% domain. The 8-puzzle is a puzzle where the player works with a board of
% size 3x3. 8 of the tiles are numbered 1-8, the remaining one is a blank.
% The user can slide each of the adjacent tiles into the blank. The goal is
% to obtain the permutation [1 2 3; 4 5 6; 7 8 B] starting from an
% arbitrary admissable state.

    properties
        invTable; %array mapping state indexes to permutations
        nConfigurations; % number of states in the MDP
    end
    
    methods        
        function As = generateActions(obj)
        % This function generats the 4-element cell array where each
        % element corresponds to an action. There are four actions, one for
        % moving the blank in one direction.
             As{1,1} = obj.generateAction(@obj.leftOfIndex);
             As{2,1} = obj.generateAction(@obj.rightOfIndex);
             As{3,1} = obj.generateAction(@obj.upOfIndex);
             As{4,1} = obj.generateAction(@obj.downOfIndex);
             As = cellfun(@packModel,As,'UniformOutput',false);
        end
        
        function A = generateAction(obj,moveFun)
        % This function generates an action model given the function
        % moveFun, which operates on state indices and describes the
        % movement. The agent obtains a reward of 1000 when reaching the
        % terminal state, moves along the way are penalized with a reward
        % of -1.
            goal = obj.permToIndex([1 2 3 4 5 6 7 8 0]);
            P = sparse(obj.nConfigurations + 1,obj.nConfigurations + 1);
            P(obj.nConfigurations + 1,obj.nConfigurations + 1) = 1;
            P(goal,obj.nConfigurations + 1) = 1;
            
            R = ones(obj.nConfigurations + 1,1) * -1;
            R(obj.nConfigurations + 1) = 0;
            R(goal) = 1000;
            
            for i=1:obj.nConfigurations
                if i ~= goal
                    P(i,moveFun(i)) = 1;
                end
            end            
            
            A.P = P;
            A.R = R;
        end
        
        function i = permToIndex(obj,p)
        % Function for mapping a permutation defining the state to the
        % state index.
            v = obj.permToVal(p);
            i = findRow(obj.invTable,v);
        end
        
        function p = indexToPerm(obj,i)
        % Function for mapping a state index to state permutation.
            v = obj.invTable(i);
            p = obj.valToPerm(v,9);
        end
                        
        function dfs(obj, p)
        % This functions enumerates all states of the puzzle, performing a
        % depth-first search. The mapping from state indices to
        % permutations is stored in the array obj.invTable.
            tmap = java.util.HashMap;
            dq = java.util.ArrayDeque();
            dq.push(p);
            
            while(~dq.isEmpty())
                p = dq.pop();
                ps = sprintf('%d',p);
                if (size(tmap.get(ps),1) > 0)
                    continue;
                end
                obj.nConfigurations = obj.nConfigurations + 1;
                tmap.put(ps,obj.nConfigurations);
                obj.invTable(obj.nConfigurations) = obj.permToVal(p);
                dq.push(obj.moveUp(p));
                dq.push(obj.moveDown(p));
                dq.push(obj.moveLeft(p));
                dq.push(obj.moveRight(p));
            end
        end
                
        function obj = EightPuzzle()
        % This functions constructs the object EightPuzzle that can be used
        % to generate actions. This entails the enumeration of all states
        % in the puzzle, using depth first search from the starting
        % configuration.
            obj.invTable = zeros(200000,1);
            obj.nConfigurations = 0;
            obj.dfs([1 2 3 4 5 6 7 8 0]);
            obj.invTable = obj.invTable(1:obj.nConfigurations);
            obj.invTable = sort(obj.invTable);
        end
        
        function p = valToPerm(obj, v, plen)
        % This function converts the number stored in v to the permutation
        % p of length p, where each element in the permutation corresponds
        % to one decimal digit of the number v. This is used to convert
        % between the permutations stored as a single number and
        % permutations stored as arrays.
            p = zeros(1,plen);
            for i=1:plen
                p(i) = mod(v,10);
                v = floor(v / 10);
            end
        end

        function v = permToVal(obj, p)
        % This function converts ther permutation stored in p into a single
        % number v, so that entries in the permutation correspond to digits
        % in the number. This is used to convert between permutations
        % stored as arrays and as numbers.
            v = 0;
            for i=1:length(p)
                v = v + p(i) * 10^(i-1);
            end
        end

        
        % The following four function model the moves possible in the
        % puzzle, working on state indices.
        
        function i2 = leftOfIndex(obj,i)
            i2 = obj.permToIndex(obj.moveLeft(obj.indexToPerm(i)));
        end
        
        function i2 = rightOfIndex(obj,i)
            i2 = obj.permToIndex(obj.moveRight(obj.indexToPerm(i)));
        end
        
        function i2 = upOfIndex(obj,i)
            i2 = obj.permToIndex(obj.moveUp(obj.indexToPerm(i)));
        end
        
        function i2 = downOfIndex(obj,i)
            i2 = obj.permToIndex(obj.moveDown(obj.indexToPerm(i)));
        end
        
        % The following four functions model the moves possible in the
        % puzzle, working on states represented as permutations.
        
        function rp = moveUp(obj,p)
            blank = find(~p);
            rp = p;
            if blank > 3
                rp([blank,blank - 3]) = rp([blank - 3,blank]);
            end
        end

        function rp = moveDown(obj,p)
            blank = find(~p);
            rp = p;
            if blank <= 6
                rp([blank,blank + 3]) = rp([blank + 3,blank]);
            end
        end

        function rp = moveRight(obj,p)
            blank = find(~p);            
            rp = p;
            if mod(blank,3) >= 1
                rp([blank,blank + 1]) = rp([blank + 1,blank]);
            end
        end

        function rp = moveLeft(obj,p)
            blank = find(~p);            
            rp = p;
            if mod(blank,3) ~= 1
                rp([blank,blank - 1]) = rp([blank - 1,blank]);
            end
        end
    end
    
end

