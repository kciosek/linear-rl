function [nA, I] = solveSubgoal(As, Phi, G, maxiter)
% This function solves the subgoal specified in the G parameter using the
% approximation framework given by the Phi matrix and the primitive actions
% (in terms of the original state space) specified in the As parameter. The
% optional maxiter paramter specifies the maximum allowed number of
% iterations. The default calue is -1, which means that we iterate until
% convergence.

    if nargin < 4
        maxiter = -1; % By default, iterate until convergence.
    end
    
    % Compress down the actions to the aggregate state space.
    pD = packP(generateD(Phi));
    pPhi = packP(Phi);
    pAs = cellfun(@(A) pD * A * pPhi ,As,'UniformOutput',false);
    
    % Add the leading one to the subgoal.
    GsA{1} = packSubgoal(G);
    
    % Define the algorithm for our iteration
    oa = OptimizePolicyAndTerminationNestedIteration(pAs,GsA,false,false);
    
    % Run the actual iteration.
    fprintf('Solving subgoal\n');
    epAggrOpModels = iterateAll(pAs{1}, oa, maxiter);
    
    % Using the obtained model, compute the option then use the option to
    % compute a model in terms of the original state space.
    fprintf('Upscaling subgoal model to original state space\n');
    [policy,term] = aggrPolicyFromSubgoal(epAggrOpModels{1},pAs,GsA{1});    
    nA = modelFromAggrPolicy(policy,term,As,Phi);
    
    % In case we did not iterate to the end because of the maxiter
    % parameter, or in case the subgoal is not reachable from some states,
    % we define the initiation set as the set of such states from which the
    % subgoal is reachable.
    bigG = pPhi * GsA{1};
    nAG = nA * bigG;
    I = nAG > subgoalVal()/2;
    I(1) = true;
end

