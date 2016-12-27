classdef EightPuzzleFeatures122344340 < EightPuzzleFeatures
% This file defines one of the features frameworks used in the 8-puzzle
% domain. The exact nature of the aggregation is specified in the numeric
% string at the end of the class name: 0 denotes a blank, and positions in
% the permutation that share the same number are interchangable in the
% approximation.
    methods
        function G = generateG(obj)
            G = zeros(obj.nAggrConfigurations + 1,1);
            Gval = subgoalVal();
            G(obj.aggrPermToAggrIndex([1 2 2 3 4 4 3 4 0])) = Gval;
        end
                
        function p = aggrMap(~)
            p = [0 1 2 2 3 4 4 3 4 9];
        end
        
        function obj = EightPuzzleFeatures122344340(ep)
            obj = obj@EightPuzzleFeatures(ep);         
        end
    end   
end

