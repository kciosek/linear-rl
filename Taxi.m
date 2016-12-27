classdef Taxi < handle
% This class contatins code required for computing the action models for
% the TAXI domain.
    methods
        function As = generateActions(obj,isDeterministic)
        % This function computes the action models for the Taxi domain.
            As{1,1} = obj.generateMoveAction(1,0,isDeterministic); 
            As{2,1} = obj.generateMoveAction(-1,0,isDeterministic);
            As{3,1} = obj.generateMoveAction(0,1,isDeterministic);
            As{4,1} = obj.generateMoveAction(0,-1,isDeterministic);
            As{5,1} = obj.generateFillupAction();
            As{6,1} = obj.generatePickupAction();
            As{7,1} = obj.generatePutdownAction();

            As = cellfun(@packModel,As,'UniformOutput',false);
        end

        function A = generatePutdownAction(obj)
            P = sparse(7001,7001);
            P(7001,7001) = 1;
            R = zeros(7001,1);
            for px=1:5
            for py=1:5
                for passenger=1:5
                    for dest=1:4
                        for fuel=0:13
                            % Index of the state we go FROM.
                            is = obj.makeStateIndex(...
                                px,py,passenger,dest,fuel);                    
                            
                            if  passenger == 5 && (...
                                 px == 1 && py == 1 && dest == 1 || ...
                                 px == 5 && py == 1 && dest == 2 || ...
                                 px == 1 && py == 5 && dest == 3 || ...
                                 px == 4 && py == 5 && dest == 4 )
                                % We go to the termination state if we have
                                % the passenger and we are in the right
                                % spot.
                                P(is,7001) = 1;                            
                                R(is) = 20;
                            else
                                % Else we stay in the same spot and there
                                % is a penalty.
                                P(is,is) = 1;
                                R(is) = -10;
                            end
                        end                
                    end
                end
           end
           end
           A.P = P;
           A.R = R;
        end


        function A = generatePickupAction(obj)
            P = sparse(7001,7001);
            P(7001,7001) = 1;
            R = zeros(7001,1);
            for px=1:5
            for py=1:5
                for passenger=1:5
                    for dest=1:4
                        for fuel=0:13
                            % Index of the state we go FROM.
                            is = obj.makeStateIndex(...
                                px,py,passenger,dest,fuel);
                            
                            % Index of the state we go TO.
                            id = obj.makeStateIndex(px,py,5,dest,fuel);
                            
                            if passenger == 1 && px == 1 && py == 1 || ...
                               passenger == 2 && px == 5 && py == 1 || ...
                               passenger == 3 && px == 1 && py == 5 || ...
                               passenger == 4 && px == 4 && py == 5
                            % If we are in the right spot and the passenger
                            % is waiting there, pick him up.
                                P(is,id) = 1;
                                R(is) = -1;
                            else
                            % Else there is a penalty.
                                P(is,is) = 1;
                                R(is) = -10;
                            end
                        end                
                    end
                end
           end
           end

           A.P = P;
           A.R = R;
        end

        function A = generateFillupAction(obj)
            P = sparse(7001,7001);
            P(7001,7001) = 1;
            for px=1:5
            for py=1:5
                for passenger=1:5
                    for dest=1:4
                        for fuel=0:13
                            % Index of state we go FROM.
                            is = obj.makeStateIndex(...
                                px,py,passenger,dest,fuel);
                            % Index of state we go TO.
                            id = obj.makeStateIndex(...
                                px,py,passenger,dest,13);
                            
                            if px == 3 && py == 4 
                                % If we are at the pump, fill up.
                                P(is,id) = 1;
                            else
                                % Else we stay where we are.
                                P(is,is) = 1;
                            end
                        end                
                    end
                end
           end
           end
           A.P = P;
           A.R = -1 * ones(7001,1);
           A.R(7001) = 0;
        end

        function A = generateMoveAction(obj,dx, dy, isDeterministic)
            P = sparse(7001,7001);
            P(7001,7001) = 1;
            R = -1 * ones(7001,1);
            R(7001) = 0;
            for px=1:5
            for py=1:5
                for passenger=1:5
                    for dest=1:4
                        for fuel=0:13
                            nx = px + dx;
                            ny = py + dy;
                            
                            % Index of the state we go FROM.
                            is = obj.makeStateIndex(...
                                px,py,passenger,dest,fuel);
                            % Index of the state we go TO.
                            id = obj.makeStateIndex(...
                                nx,ny,passenger,dest,fuel-1);
                            
                            if nx == 0 || ny == 0 || nx == 6 || ny == 6 ...
                                || py <= 2 && ...
                                 (px == 2 && nx == 3 || px == 3 && nx == 2) ...
                                || py >= 4 && ...
                                 (px == 1 && nx == 2 || px == 2 && nx == 1) ...
                                || py >= 4 && ...
                                 (px == 3 && nx == 4 || px == 4 && nx == 3) ...
                                || fuel == 0
                                %If there is a wall on the way, we stay
                                %where we are.
                                P(is,is) = 1;
                                if (fuel == 0)
                                    R(is) = 0;
                                end
                            else
                                % Else we move to the destination state,
                                % possibly with a non-deterministic staying
                                % probability in the original state.
                                if isDeterministic
                                    P(is,id) = 1;
                                else
                                    P(is,id) = 0.95;
                                    P(is,is) = 0.05;
                                end
                            end
                        end                
                    end
                end
           end
           end
           A.P = P;
           A.R = R;
        end
        
        function index = makeStateIndex(...
            obj,posx, posy, passenger, dest, fuel)
        % This function converts a description of the state to a numerical 
        % index. The parameters are as follows:
        % posx, posy (form 1 to 5) - positions of the taxi in the grid
        % passenger (from 1 to 5) - position of the passenger:
        %                           1-R,2-G,3-Y,4-B,5-taxi
        % dest (from 1 to 4) - the destination of the passenger
        % fuel (from 0 to 13) - the amount of fuel
            index = 1 + (posx-1) + (posy-1)*5 + (passenger-1)*5*5 + ...
                   (dest-1)*5*5*5 + fuel*5*5*5*4;
        end
        
        function G = cellSubgoal(obj,px,py)
        % Make subgoal which is to go the cell specified by px and py.
            G = sparse(7001,1);
            for passenger=1:5
                for dest=1:4
                    for fuel=0:13                   
                        is = obj.makeStateIndex(px,py,passenger,dest,fuel);
                        G(is) = 1000;
                    end                
                end
            end
            G = packSubgoal(G);
        end
        
    end
end

