classdef TaxiRunner  < handle    
%This class contatins methods for running experiments in the TAXI domain.
    methods(Static)
        function V = vi(isDeterministic)
        % This function runs standard value iteration (with matrix models).
        % The return value is a vector containing the optimum value 
        % function.
        % The parameter isDeterministic determines if we use the
        % deterministic or nondeterministic version of the problem.
            
            % Initialize the subgoal. Since this is value iteration we just
            % have one sugoal, set everywhere to zero.
            GsA{1} = packSubgoal(sparse(7001,1));
            
            % Generate the action models.
            taxi = Taxi();
            As = taxi.generateActions(isDeterministic);
            
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
            taxi = Taxi();
            As = taxi.generateActions(isDeterministic);
            
            % Run the algorithm.
            Vp = plainValueIteration(As);
            
            % Extract the value function.
            V = Vp(2:end);
        end
        
        function V = options(isDeterministic)
        % This function runs our options algorithm. The return value is
        % a vector containing the optimum value function.
        % The parameter isDeterministic determines if we use the
        % deterministic or nondeterministic version of the problem.
        % In addition to the main subgoalm there are five subgoals, one for
        % going to each of the pickup locations and one for the pump.
            
            %Initialize the object for generating models in our domain.
            taxi = Taxi();
            
            % Initialize the subgoals. The first subgoal corresponds to 
            % optimizing the total reward, so it is set uniformly to zero.
            % The other subgoals correspond to going to a specified
            % location on the board.
            GsA{1} = packSubgoal(sparse(7001,1));
            GsA{2} = taxi.cellSubgoal(3,4);
            GsA{3} = taxi.cellSubgoal(1,1);
            GsA{4} = taxi.cellSubgoal(5,1);
            GsA{5} = taxi.cellSubgoal(1,5);
            GsA{6} = taxi.cellSubgoal(4,5);            
            
            % Generate the action models.
            As = taxi.generateActions(isDeterministic);
            
            % Our initial model is the first action. This guarantees that 
            % we start with a valid model.
            im = As{1};
            
            % Initialize the iteration algorithm with our action set and
            % subgoal set.
            ia = OptimizePolicyAndTerminationNestedIteration(As,GsA,true);
            
            % Do the actual iteration.
            models = iterateAll(im, ia);            
            
            % Extract the optimum value function from the reward part of
            % the resulting model.
            V = models{1}(2:end,1);
        end
        
        function V = aggregation(isDeterministic)
        % This function runs standard value iteration two times. First, the
        % aglorithm runs in the approximate state space, which only takes
        % into account the location in the gridworld. Then the solution is
        % used to initialize the iteration in the original state space. The 
        % return value is a vector containing the optimum value function.
        % The parameter isDeterministic determines if we use the
        % deterministic or nondeterministic version of the problem.

            % Initialize the objects for generating models in our domain, 
            % and for generating the features.
            taxi = Taxi();
            tf = TaxiFeaturesPositionOnly(taxi);
        
            % Initialize the subgoal value for the aggregate problem.
            GsAa{1} = tf.generateG();
            
            % Generate the action models. First we generate the actions in
            % the original state space. Then we generate the feature matrix
            % Phi and downproject the actions to the aggregate state space.
            As = taxi.generateActions(isDeterministic);            
            Phi = tf.generatePhi();
            pD = packP(generateD(Phi));
            pPhi = packP(Phi);
            pAs = cellfun(@(A) pD * A * pPhi ,As,'UniformOutput',false);
                        
            % Initialize the iteration algorithm for the aggregate domain 
            % with our action set and subgoal set.
            iaa = OptimizePolicyAndTerminationNestedIteration(...
                        pAs,GsAa,false);
            
            % Do the actual iteration in the aggregate domain.
            amodels = iterateAll(pAs{1}, iaa);
            
            % Compute the optimum value function and upscale it back to the
            % original state space.
            aggregateV = amodels{1}(1:end,1);
            interpolatedVal = pPhi * aggregateV;

            % Construct a greedy model, based on the interpolated value
            % function.
            im = makeGreedyModel(interpolatedVal,As);
            
            % Initialize the subgoal. Since this is value iteration we just
            % have one sugoal, set everywhere to zero.
            GsA{1} = packSubgoal(sparse(7001,1));
            
            % Initialize the iteration algorithm with our action set and
            % subgoal set.
            ia = OptimizePolicyAndTerminationNestedIteration(As,GsA,false);
            
            % Do the actual iteration.
            models = iterateAll(im, ia);
            
            % Extract the optimum value function from the reward part of
            % the resulting model.
            V = models{1}(2:end,1);
        end
        
        function V = optionsAggregation(isDeterministic)
        % This function first runs standard value iteration on the five 
        % subgoals simultanously, obtaining five models in the aggregate 
        % state space that take the agent to one of the five locations.
        % Then thes models are upscaled to the full size of the state space
        % and used instead of the primitive actions for moving in the final
        % value iteration. The final iteration occurs with model VI.
        % The return value is a vector containing the optimum value 
        % function. The parameter isDeterministic determines if we use the
        % deterministic or nondeterministic version of the problem.
            
            % Initialize the objects for generating models in our domain, 
            % and for generating the features.
            taxi = Taxi();
            tf = TaxiFeaturesPositionOnly(taxi);
        
            % Generate the action models. First we generate the actions in
            % the original state space. Then we generate the feature matrix
            % Phi and downproject the actions to the aggregate state space.
            As = taxi.generateActions(isDeterministic);            
            Phi = tf.generatePhi();
            pD = packP(generateD(Phi));
            pPhi = packP(Phi);
            pAs = cellfun(@(A) pD * A * pPhi ,As,'UniformOutput',false);
        
            % Initialize the subgoal values for the aggregate problem.
            GsAa{1} = sparse(pD * taxi.cellSubgoal(3,4)); %F
            GsAa{2} = sparse(pD * taxi.cellSubgoal(1,1)); %R
            GsAa{3} = sparse(pD * taxi.cellSubgoal(5,1)); %G
            GsAa{4} = sparse(pD * taxi.cellSubgoal(1,5)); %Y
            GsAa{5} = sparse(pD * taxi.cellSubgoal(4,5)); %B

            % Initialize the iteration algorithm for the aggregate domain 
            % with our action set and subgoal set.
            iaa = OptimizePolicyAndTerminationNestedIteration(...
                     pAs(1:4),GsAa,false,false);
            
            % Solve for all the subgoals simultanously
            amodels = iterateAll(pAs{1}, iaa);

            % Upscale the models to the original state space. This is a
            % two-step process. First, the option (policy + termination
            % condition) over the aggregare state space is computed. Then
            % this policy is applied, using the aggregation probabilities,
            % to the original state space. Then a model is created in the
            % original state space which evaluates the option to the end.
            newAs = cell(5,1);
            for si = 1:5
                [policy,term] = aggrPolicyFromSubgoal(...
                                        amodels{si},pAs,GsAa{si});
                newAs{si,1} = modelFromAggrPolicy(policy,term,As,Phi);
            end
            
            % Our new action set consists of the old primitive actions for
            % pickup, dropdown and refuelling, in addition to the new
            % models for moving around we have just computed.
            Asm = [As(5:end); newAs];

            % Initialize the subgoal. Since this is value iteration we just
            % have one sugoal, set everywhere to zero.
            GsA{1} = packSubgoal(sparse(7001,1));
            
            % Initialize the iteration algorithm with our action set and
            % subgoal set.
            ia = OptimizePolicyAndTerminationNestedIteration(...
                    Asm,GsA,false);
            
            % Do the actual iteration, in terms of the original state 
            % space.
            models = iterateAll(As{1}, ia);
                        
            % Extract the optimum value function from the reward part of
            % the resulting model.
            V = models{1}(2:end,1);
        end
        
        function V = optionsAggregationPlain(isDeterministic)
        % This function first runs standard value iteration on the five 
        % subgoals simultanously, obtaining five models in the aggregate 
        % state space that take the agent to one of the five locations.
        % Then thes models are upscaled to the full size of the state space
        % and used instead of the primitive actions for moving in the final
        % value iteration. The final iteration occurs with plain VI.
        % The return value is a vector containing the optimum value 
        % function. The parameter isDeterministic determines if we use the
        % deterministic or nondeterministic version of the problem.
            
            % Initialize the objects for generating models in our domain, 
            % and for generating the features.
            taxi = Taxi();
            tf = TaxiFeaturesPositionOnly(taxi);
        
            % Generate the action models. First we generate the actions in
            % the original state space. Then we generate the feature matrix
            % Phi and downproject the actions to the aggregate state space.
            As = taxi.generateActions(isDeterministic);            
            Phi = tf.generatePhi();
            pD = packP(generateD(Phi));
            pPhi = packP(Phi);
            pAs = cellfun(@(A) pD * A * pPhi ,As,'UniformOutput',false);
        
            % Initialize the subgoal values for the aggregate problem.
            GsAa{1} = sparse(pD * taxi.cellSubgoal(3,4)); %F
            GsAa{2} = sparse(pD * taxi.cellSubgoal(1,1)); %R
            GsAa{3} = sparse(pD * taxi.cellSubgoal(5,1)); %G
            GsAa{4} = sparse(pD * taxi.cellSubgoal(1,5)); %Y
            GsAa{5} = sparse(pD * taxi.cellSubgoal(4,5)); %B

            % Initialize the iteration algorithm for the aggregate domain 
            % with our action set and subgoal set.
            iaa = OptimizePolicyAndTerminationNestedIteration(...
                     pAs(1:4),GsAa,false,false);
            
            % Solve for all the subgoals simultanously
            amodels = iterateAll(pAs{1}, iaa);

            % Upscale the models to the original state space. This is a
            % two-step process. First, the option (policy + termination
            % condition) over the aggregare state space is computed. Then
            % this policy is applied, using the aggregation probabilities,
            % to the original state space. Then a model is created in the
            % original state space which evaluates the option to the end.
            newAs = cell(5,1);
            for si = 1:5
                [policy,term] = aggrPolicyFromSubgoal(...
                                        amodels{si},pAs,GsAa{si});
                newAs{si,1} = modelFromAggrPolicy(policy,term,As,Phi);
            end
            
            % Our new action set consists of the old primitive actions for
            % pickup, dropdown and refuelling, in addition to the new
            % models for moving around we have just computed.
            Asm = [As(5:end); newAs];

            % Run the algorithm.
            Vp = plainValueIteration(Asm);
            
            % Extract the value function.
            V = Vp(2:end);
        end
        
        function V = aggregationApproximate(isDeterministic)
        % This function runs model value iteration. However the problem
        % that is being solved is the aggregate problem - the optimum value
        % function we get here is optimal only for the aggregate state 
        % space, it is *not* optimal for the original problem. The length
        % of the returned value function is still the number of the
        % original states, since we upscale the result from the aggregate
        % setting. The aggregation is set up to ignore the fuel variable 
        % and the resulting value function induces a policy which tries to
        % solve TAXI while ignoring fuel. This demostrates that the 
        % aggregation framework can be meaningfully used to quickly produce
        % an approzimate solution if solving the full problem is too 
        % costly. The parameter isDeterministic determines if we use the 
        % deterministic or nondeterministic version of the problem.            
                      
            % Initialize the objects for generating models in our domain, 
            % and for generating the features.
            taxi = Taxi();
            tf = TaxiFeaturesIgnoreFuel(taxi);
        
            % Initialize the subgoal value for the aggregate problem.
            GsAa{1} = tf.generateG();
            
            % Generate the action models. First we generate the actions in
            % the original state space. Then we generate the feature matrix
            % Phi and downproject the actions to the aggregate state space.
            As = taxi.generateActions(isDeterministic);            
            Phi = tf.generatePhi();
            pD = packP(generateD(Phi));
            pPhi = packP(Phi);
            pAs = cellfun(@(A) pD * A * pPhi ,As,'UniformOutput',false);
                        
            % Initialize the iteration algorithm for the aggregate domain 
            % with our action set and subgoal set.
            iaa = OptimizePolicyAndTerminationNestedIteration(...
                        pAs,GsAa,false);
            
            % Do the actual iteration in the aggregate domain.
            amodels = iterateAll(pAs{1}, iaa);
            
            % Compute the option corresponding to the obtained approximate
            % model.
            [policy,term] = aggrPolicyFromSubgoal(...
                amodels{1},pAs,GsAa{1});
            
            % Use the option to upscale the model to the original state
            % space. This model solves the original problem only
            % *approximately*.
            upscaledModel = modelFromAggrPolicy(policy,term,As,Phi);
                    
            % Extract the approximate optimum value function from the 
            % reward part of the resulting model.
            V = upscaledModel(2:end,1);
        end
                        
        function V = aggregationApproximatePlain(isDeterministic)
        % This function runs plain value iteration. However the problem
        % that is being solved is the aggregate problem - the optimum value
        % function we get here is optimal only for the aggregate state 
        % space, it is *not* optimal for the original problem. The length
        % of the returned value function is still the number of the
        % original states, since we upscale the result from the aggregate
        % setting. The aggregation is set up to ignore the fuel variable 
        % and the resulting value function induces a policy which tries to
        % solve TAXI while ignoring fuel. This demostrates that the 
        % aggregation framework can be meaningfully used to quickly produce
        % an approzimate solution if solving the full problem is too 
        % costly. The parameter isDeterministic determines if we use the 
        % deterministic or nondeterministic version of the problem.            
                      
            % Initialize the objects for generating models in our domain, 
            % and for generating the features.
            taxi = Taxi();
            tf = TaxiFeaturesIgnoreFuel(taxi);
                    
            % Generate the action models. First we generate the actions in
            % the original state space. Then we generate the feature matrix
            % Phi and downproject the actions to the aggregate state space.
            As = taxi.generateActions(isDeterministic);            
            Phi = tf.generatePhi();
            pD = packP(generateD(Phi));
            pPhi = packP(Phi);
            pAs = cellfun(@(A) pD * A * pPhi ,As,'UniformOutput',false);
                        
            % Run the algorithm.
            aggregateV = plainValueIteration(pAs);
            V = aggregateV(2:end);
            
            %Upscale 
            %interpolatedV = pPhi * aggregateV;
            
            % Extract the value function.
            %V = interpolatedV(2:end);                        
        end
                
    end
end

