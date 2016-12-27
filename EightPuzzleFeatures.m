classdef EightPuzzleFeatures < handle
% This is a class which serves as the base class for classes generating
% features in the 8-puzzle domain. Subclasses of this type should define
% the methods generateG and permToAggrPerm, which define the specifics of
% the approximation architecture used.
    
    properties
        ep; % The EightPuzzle object
        aggrTable; % Mapping from indexes to values representing 
                   % permutations of aggregate states.
        nAggrConfigurations; % Number of aggregate states
        Phi; % The aggregation matrix.
        G;   % The subgoal vector.
    end
    
    methods (Abstract)
        G = generateG(obj);
        % This method should generate the vector G. States that are
        % subgoals should have high values in this vector.
               
        p = aggrMap(obj);
        %This method defines the aggregation framework in that it converts
        %the description in the original state space into a description in
        %the aggregate space. In the original state space, fields are
        %denoted 1-9 and the blank is denoted zero. The map:
        %[0 1 2 3 4 5 6 7 8 9] will leave that unchanged (i.e. the number 
        %of aggregate states will be the same as the original states. On 
        %the other hand, the map [0 1 1 1 4 5 6 7 8 9] will assign states
        %from the first row to a single group.
    end
    
    methods
        function Phi = generatePhi(obj)
        % This function generates the aggregation matrix for the 8-puzzle
        % problem. The correspondence between aggregate states and original
        % states is computed using the function obj.aggrPermToAggrIndex.
            Phir = 1:(obj.ep.nConfigurations + 1);
            Phic = zeros(obj.ep.nConfigurations + 1, 1);
            v = ones(obj.ep.nConfigurations + 1, 1);
            map = obj.aggrMap();
            for i=1:obj.ep.nConfigurations
                  val = obj.ep.invTable(i);
                  aval = changeDigits(val,map,9);                                            
                  Phic(i) = findRow(obj.aggrTable,aval);
            end
            Phic(end) = obj.nAggrConfigurations + 1;
            Phi = sparse(Phir,Phic,v,obj.ep.nConfigurations + 1, ...
                obj.nAggrConfigurations + 1);
        end
     
        function initAggr(obj)
        % This function initializes the mapping obj.aggrTable between
        % indexes of aggregate states and values representing permutations 
        % in the aggregate space.
            obj.aggrTable = zeros(obj.ep.nConfigurations,1);
            map = obj.aggrMap();
            for i=1:obj.ep.nConfigurations
                val = obj.ep.invTable(i);
                aval = changeDigits(val,map,9);
                obj.aggrTable(i) = aval; 
            end
            obj.aggrTable = sort(unique(obj.aggrTable, 'rows'));
            obj.nAggrConfigurations = size(obj.aggrTable,1);
        end
                        
        function i = aggrPermToAggrIndex(obj,p)
        % Convert the permutation over the aggregate state space to
        % aggregate state index.
            v = obj.ep.permToVal(p);
            i = findRow(obj.aggrTable,v);
        end
                               
        function obj = EightPuzzleFeatures(ep)
        % Construct the object used to make the features. This involves
        % iterating over all the states in the original state space to
        % obtain the corresponding aggregate state. 
            obj.ep = ep;
            obj.initAggr();
            obj.Phi = obj.generatePhi();
            obj.G = obj.generateG();
        end
    end
end
