function [policy,term] = aggrPolicyFromSubgoal(model, As, G)
% This function, given a model, a set of primitive actions and a subgoal,
% computes the options (policy + termination condition) that, if followed,
% solve the particular subgoal. The model given should be obtained by
% running the iteration to solve the subgoal.
    policy = zeros(size(model,1)-1,1);
    
    % First, we allocate memory for modelm - it will contain rows from the
    % identity matrix where termination is best and rows from our initial
    % model where continuation is best.
    modelm = model;
    modelG = model * G;
    
    termf = G > modelG; % This contatins 1 in the first entry.
    term = termf(2:end); % This has length equal to the number of states.
    
    sz = size(model,1);
    speye = sparse(1:sz,1:sz,ones(1,sz),sz,sz); % Sparse eye.
    % Assign rows of modelm where we terminate to be rows from sparse eye.
    modelm(termf,:) = speye(termf,:); 
    
    
    % We precompute this for speed
    modelmGt =  (modelm * G)';
    
    % For speed, it is faster to work with trasposed actions.
    Ast = cellfun(@(m) m', As,'UniformOutput',false);
    
    % This loop picks the action that maximizes Action(r,:)*modelm*G for
    % each row. We work in the transposed setting (i.e. with columns, not
    % rows) for speed.
    for r=2:size(model,1)
        max_val = -realmax;
        for ai=1:length(As)
           val = modelmGt * Ast{ai}(:,r) ;
                
            if val >= max_val
                max_val = val;
                policy(r-1) = ai;
            end
        end        
    end
end

