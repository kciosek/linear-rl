function Ms = iterateAll(initialModel, iterationAlgorithm, maxiter)
% This function is responsible for iterating the chosen algorithm on the
% models. The algorithm is specified in the iterationAlgorithm parameter.
% The initialModel parameter specifies the initial models from which the
% iterations starts. The maxiter parameter specifies the maximum number of
% iterations the algorithm should run. Use -1 or skip this parameter to 
% denote that it should run until convergence. The iteration takes place on
% all models simultanously.
% The return variable models contatins the state of the models after
% termination (i.e. after maxiter iterations or after convergence).
    
    % If the user has not specified the maximum number of iterations, we
    % iterate until convergence.
    if nargin < 3
        maxiter = -1;
    end
    
    % We initialize all our models to the value specified by the user.
    Ms = cell(length(iterationAlgorithm.Gs),1);
    for i=1:length(Ms)
        Ms{i} = initialModel;
    end
        
    iter = 1;
    cnorm = realmax;
    
    fprintf('Iteration: ');
    
    % We terminate in case of convergence (cnorm is small) or in case
    % where the maximum number of iterations has been reached.
    while cnorm > 0.001 && iter ~= maxiter + 1
        fprintf('%d ', iter);        
        Msnew = iterationAlgorithm.iterate(Ms);
        
        % The norm we compute is the difference between each model value
        % function wrt. the subgoal in the last two iterations.
        cnorm = 0;
        for i=1:length(iterationAlgorithm.Gs)
           cnorm = cnorm + norm((Msnew{i} - Ms{i})*...
                                        iterationAlgorithm.Gs{i}); 
        end
                
        Ms = Msnew;        
        iter = iter + 1;
    end 
    
    fprintf('done.\n');
end
