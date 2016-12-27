classdef HanoiRunner  < handle    
%This class contatins methods for running experiments in the Hanoi domain.
    methods(Static)
        function V = vi(isDeterministic)
        % This function runs standard value iteration (with matrix models).
        % The return value is a vector containing the optimum value 
        % function.
        % The parameter isDeterministic determines if we use the
        % deterministic or nondeterministic version of the problem.      
                        
            % Generate the action models.
            h = Hanoi(8);
            As = h.generateActions(isDeterministic);
            
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
        
        function V = plainVi(isDeterministic)
        % This function runs plain value iteration (without matrix models).
        % The return value is a vector containing the optimum value 
        % function.
        % The parameter isDeterministic determines if we use the
        % deterministic or nondeterministic version of the problem.      

            % Generate the action models.
            h = Hanoi(8);
            As = h.generateActions(isDeterministic);
            
            % Run the algorithm.
            Vp = plainValueIteration(As);
            
            % Extract the value function.
            V = Vp(2:end);
        end
        
        function V = optionsAggregation(isDeterministic)
        % This function solves the Hanoi problem using the following 
        % procedure: First, the problem with two disks is solved, then the
        % solution is used to solve the problem with 3 disks, then the
        % solution to this is used to solve 4 disks and so on. The return 
        % value is a vector containing the optimum value function.
        % The parameter isDeterministic determines if we use the
        % deterministic or nondeterministic version of the problem.      
                        
            % Generate the action models.
            disks = 8;
            h = Hanoi(disks);
            As = h.generateActions(isDeterministic);
            
            % Iterate over problems with number of disks from 2 to disks-1.
            % In each case, the solution to the previous problem is passed
            % as an additional action to the algorithm solving the next
            % problem. 
            newAs = [];
            for s=2:(disks-1)
                newAs = HanoiRunner.subproblem(h,s,[As; newAs]);
            end
            
            % We add the action for solving the problem of size disks-1 to
            % our action set for the main problem.
            Asm = [As; newAs];
                      
            % Initialize the subgoal. Since this is value iteration we just
            % have one sugoal, set everywhere to zero.
            GsA{1} = packSubgoal(sparse(size(Asm{1},1)-1,1));

            % Our initial model is the first action. This guarantees that 
            % we start with a valid model.
            im = Asm{1};
            
            % Initialize the iteration algorithm with our action set and
            % subgoal set.
            ia = OptimizePolicyAndTerminationNestedIteration(...
                                                        Asm,GsA,false);
            
            % Do the actual iteration.
            fprintf('Solving main goal\n');
            models = iterateAll(im, ia);
            
            % Extract the optimum value function from the reward part of
            % the resulting model.
            V = models{1}(2:end,1);
        end
        
        function newAs = subproblem(bigHanoi,m,As)
        % This is a elper function that solves the Hanoi problem with m
        % disks as using actions from the set As, considered as a subroblem
        % of the bigger problem defined by the parameter bigHanoi. The
        % problem is solved for all three subgoals (they correspond to
        % placing all disks on peg A,B and C, respectively.
            hf = HanoiFeatures(m,bigHanoi);
            Phi = hf.generatePhi();
            Ga = hf.generateG(1);
            Gb = hf.generateG(2);
            Gc = hf.generateG(3);

            newAs{1,1} = solveSubgoal(As, Phi, Ga);
            newAs{2,1} = solveSubgoal(As, Phi, Gb);
            newAs{3,1} = solveSubgoal(As, Phi, Gc);
        end
        
    end
end

