classdef TaxiFeaturesIgnoreFuel < handle
% This class definies methods that serve to generate the approximation
% architecture for the TAXI problem. The approximation ignores the fuel
% variable, leaving the other varaibles unchanged.
    properties        
        taxi; % The object used to generate the TAXI domain.
    end
    
    methods
        function obj = TaxiFeaturesIgnoreFuel(taxi)
            obj.taxi = taxi;
        end
        
        function Phi = generatePhi(obj)
            Phi = zeros(7001,25*4*5+1);
            for px=1:5
            for py=1:5
                for passenger=1:5
                    for dest=1:4
                        for fuel=0:13                   
                            is = obj.taxi.makeStateIndex(...
                                    px,py,passenger,dest,fuel);
                            ia = obj.taxi.makeStateIndex(...
                                    px,py,passenger,dest,0);
                            Phi(is,ia) = 1;
                        end                
                    end
                end
           end
           end
           Phi(7001,25*4*5+1) = 1;
        end
        
        function G = generateG(~)
        % Initialize the subgoal for the aggregate state space. Since 
        % this is value iteration we just have one sugoal, set 
        % everywhere to zero.
            G = packSubgoal(sparse(25*4*5+1,1));
        end
        
        function index = makeAggrStateIndex(~, x, y)
             index = x + (y-1)*5;
        end
    end    
end

