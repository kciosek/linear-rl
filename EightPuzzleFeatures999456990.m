classdef EightPuzzleFeatures999456990 < EightPuzzleFeatures
% This file defines one of the features frameworks used in the 8-puzzle
% domain. The exact nature of the aggregation is specified in the numeric
% string at the end of the class name: 0 denotes a blank, and positions in
% the permutation that share the same number are interchangable in the
% approximation.
    methods
        function G = generateG(obj)
            G = zeros(obj.nAggrConfigurations + 1,1);
            Gval = subgoalVal();
            G(obj.aggrPermToAggrIndex([9 9 9 4 5 6 9 9 0])) = Gval;
            G(obj.aggrPermToAggrIndex([9 9 9 4 5 6 9 0 9])) = Gval;
            G(obj.aggrPermToAggrIndex([9 9 9 4 5 6 0 9 9])) = Gval;
            G(obj.aggrPermToAggrIndex([9 9 0 4 5 6 9 9 9])) = Gval;
            G(obj.aggrPermToAggrIndex([9 0 9 4 5 6 9 9 9])) = Gval;
            G(obj.aggrPermToAggrIndex([0 9 9 4 5 6 9 9 9])) = Gval;            
         end
                
        function p = aggrMap(~)
            p = [0 9 9 9 4 5 6 9 9 9];
        end
        
        function obj = EightPuzzleFeatures999456990(ep)
            obj = obj@EightPuzzleFeatures(ep);         
        end
    end   
end

