classdef TaxiFeaturesPositionOnly < handle
% This class definies methods that serve to generate the approximation
% architecture for the TAXI problem. The approximation only looks at the
% position of the taxi in the gridworld, ignoring the other variables.
    properties        
        taxi; % The object used to generate the TAXI domain.
    end
    
    methods
        function obj = TaxiFeaturesPositionOnly(taxi)
            obj.taxi = taxi;
        end
        
        function Phi = generatePhi(obj)
            Phi = zeros(7001,26);
            for px=1:5
            for py=1:5
                for passenger=1:5
                    for dest=1:4
                        for fuel=0:13                   
                            is = obj.taxi.makeStateIndex(...
                                px,py,passenger,dest,fuel);
                            ia = obj.makeAggrStateIndex(px,py);
                            Phi(is,ia) = 1;
                        end                
                    end
                end
           end
           end
           Phi(7001,26) = 1;
        end
        
        function G = generateG(obj)
        % Initialize the subgoal for the aggregate state space. Since 
        % this is value iteration we just have one sugoal, set 
        % everywhere to zero.
            G = packSubgoal(sparse(26,1));
        end
        
        function index = makeAggrStateIndex(~, x, y)
             index = x + (y-1)*5;
        end
    end    
end

