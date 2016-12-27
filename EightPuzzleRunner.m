classdef EightPuzzleRunner < handle
% This class containt functions for running experiments in the 8-puzzle
% domain.
   
    methods(Static)
        function [As,ep] = prepare()
        % This function initializes the problem domain and generates the
        % action matrices. This will take some time (303 seconds on our 
        % test computer), since there are as many as 181441 states in the 
        % 8-puzzle domain.
            fprintf('Preparing the 8-puzzle domain.\n');
            ep = EightPuzzle;
            As = ep.generateActions();
        end
        
        function V = vi(As,ep)
        % This function runs standard value iteration (with matrix models).
        % The return value is a vector containing the optimum value 
        % function.
                        
            % Initialize the subgoal. Since this is value iteration we just
            % have one sugoal, set everywhere to zero.
            GsA{1} = packSubgoal(sparse(size(As{1},1)-1,1));
            
            % Our initial model is the first action. This guarantees that 
            % we start with a valid model.
            im = As{1};
            
            % Initialize the iteration algorithm with our action set and
            % subgoal set.
            ia = OptimizePolicyAndTerminationNestedIteration(As,GsA,false);
            
            % Do the actual iteration.
            models = iterateAll(im, ia);
            
            % Extract the optimum value function from the reward part of
            % the resulting model.
            V = models{1}(2:end,1);
        end
        
        function V = plainVi(As,ep)
        % This function runs plain value iteration (without matrix models).
        % The return value is a vector containing the optimum value 
        % function.

            % Run the algorithm
            Vp = plainValueIteration(As);
            
            % Extreact the value function.
            V = Vp(2:end);
        end
        
        function V = optionsAggregation(As, ep, subgoalNos, horizon)
        % This function uses our options algorithm. The paramters As and ep 
        % specify the actions and the EightPuzzle object used to generate 
        % them. The paramter subgoalNos is a vector containing the indices 
        % of subgoals we use do speed up the iteration. The horizon 
        % parameter specifies the number of steps for which we try to solve
        % the subgoals. Use -1 to solve until convergence. The return value
        % is a vector containing the optimum value function.
        
            newAs = cell(length(subgoalNos),1);
            newIs = cell(length(subgoalNos),1);

            for si=1:length(subgoalNos)
                fprintf('Generating subgoal %d.\n',subgoalNos(si));
                [Phi,G] = EightPuzzleRunner.generateSubgoal(...
                                                subgoalNos(si),ep);
                [newAs{si},newIs{si}] = solveSubgoal(As, Phi, G, horizon);
            end
            
            % The new action set consists of the old actions and the models
            % learned from the subgoals.
            Asm = [As; newAs];
            
            % The initiation sets for the primitive actions are full.
            Ism = [makeFullIs(length(As),size(As{1},1)); newIs];
                                                                  
            % Do the actual iteration.
            fprintf('Solving main goal\n');
            
            % Run the algorithm
            Vp = plainValueIteration(Asm, Ism);
            
            % Extreact the value function.
            V = Vp(2:end);
        end
        
        function V = optionsChain(As, ep)
        % This function uses our options algorithm. We first solve for
        % subgoals 1 and 4. The we use subgoas 1,4 to solve for subgoal 7
        % and subgoal 1 to solve for subgoal 8. We then use subgoals 7 and
        % 8 to solve the original problem.
            
            % First, we solve the subgoals and generate the corresponding
            % models.
            
            fprintf('Generating subgoal 1.\n');
            [Phi1,G1] = EightPuzzleRunner.generateSubgoal(1,ep);
            model1 = solveSubgoal(As, Phi1, G1, -1);
            
            fprintf('Generating subgoal 4.\n');
            [Phi4,G4] = EightPuzzleRunner.generateSubgoal(4,ep);
            model4 = solveSubgoal(As, Phi4, G4, -1);
                                    
            fprintf('Generating subgoal 7\n');
            [Phi7,G7] = EightPuzzleRunner.generateSubgoal(7,ep);
            [model7,is7] = solveSubgoal([As; {model1}; {model4}], ...
                                                        Phi7, G7, -1);            
            
            fprintf('Generating subgoal 8.\n');
            [Phi8,G8] = EightPuzzleRunner.generateSubgoal(8,ep);
            [model8,is8] = solveSubgoal([As; {model1}], Phi8, G8, -1);
            
            % We will use models for subgoals 7 and 7 to solve our original
            % goal.
            newAs = {model7; model8};
            newIs = {is7; is8};
            
            % The new action set consists of the old actions and the models
            % learned from the subgoals.
            Asm = [As; newAs];
            
            % The initiation sets for the primitive actions are full.
            Ism = [makeFullIs(length(As),size(As{1},1)); newIs];
                                
            % Do the actual iteration.
            fprintf('Solving main goal\n');
            
            % Run the algorithm
            Vp = plainValueIteration(Asm, Ism);
            
            % Extreact the value function.
            V = Vp(2:end);
        end
        
        function [Phi,G] = generateSubgoal(subgoalNo, ep)
        % This is a helper function which generates the aggregation matrix
        % and the subgoal vector from one of a number of predefined values
        % of the subgoal index.            
            switch subgoalNo
                case 1
                    epf = EightPuzzleFeatures123999990(ep);
                case 2
                    epf = EightPuzzleFeatures999456990(ep);
                case 3
                    epf = EightPuzzleFeatures999999780(ep);
                case 4
                    epf = EightPuzzleFeatures199499790(ep);
                case 5
                    epf = EightPuzzleFeatures929959980(ep);
                case 6
                    epf = EightPuzzleFeatures993996990(ep);
                case 7
                    epf = EightPuzzleFeatures123499790(ep);
                case 8
                    epf = EightPuzzleFeatures123459990(ep);
                case 9
                    epf = EightPuzzleFeatures123459790(ep);
                case 10
                    epf = EightPuzzleFeatures111222330(ep);
                case 11
                    epf = EightPuzzleFeatures111122120(ep);
                case 12
                    epf = EightPuzzleFeatures112112220(ep);
                case 13
                    epf = EightPuzzleFeatures111233230(ep);
                case 14
                    epf = EightPuzzleFeatures122344340(ep);
                case 15
                    epf = EightPuzzleFeatures123123120(ep);                    
                otherwise
                    fprintf('Error in generateSubgoal - bas subgoal no.');
                    assert(false);
            end
            
        	Phi = epf.Phi;
            G = epf.G;
        end
    end    
end

