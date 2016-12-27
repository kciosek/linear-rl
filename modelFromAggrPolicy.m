function M = modelFromAggrPolicy(policy, term, As, Phi)
% This function takes a policy and a termination condition defined over the
% aggregate states, the set of primitive actions As and the aggregation
% matrix Phi. It return a model over the original state space, which
% evaluates the given option (policy+ termination condition) to the end.
% Because we optimized for speed, this function only works for hard state
% aggregation (i.e. Phi contains zeros and ones only).
    
    % First, we compute fval - fval(r-1) contains the index of the
    % aggregate state corresponding to state r.
    [r,c,~] = find(Phi);
    sm = sortrows([r,c],1);
    fval = sm(:,2);
    
    % We operate with transposed models for speed.
    Ast = cellfun(@(m) m',As,'UniformOutput',false);
    
    % M is a model which, for each state r : 1/ contains the row r
    % corresponding to the action chosen by the policy for the
    % corresponding aggregate state, if the state is non-terminating or
    % else, if the state is terminating, 2/ contains the row of the
    % indentity matrix.
    M = oneStep(As,Ast,fval,term,policy);
    
    % Exponentiate M to compute option to the end.
    M = M ^ size(As{1},1);    
                      
    % Valid models are not allowed to stand still - we have to remove the
    % rows from the identity matrix that we put in in the first step.
    
    % This matrix is analogous to the first one, except no rows are
    % substituted for the identity.
    Mfull = oneStep(As,Ast,fval,false(length(term),1),policy);
    
    % We substitute the rows which were taken from the identity matrix with
    % one-step models taken from the actions.
    term_of_r_p = [false; term(fval)];
    M(term_of_r_p,:) = Mfull(term_of_r_p,:);
end

function M = oneStep(As,Ast,fval,term,policy)
% This function builds up a one-step model in terms of the original state 
% space from the option specified. The unoptimized code for this function
% looks like this:
%
% for r=2:size(As{1},1)
%     as = find(Phi(r-1,:));
%     if term(as)
%         Mt(:,r) = sparse(r,1,1,size(As{1},1),1);
%     else
%         Mt(:,r) = Ast{policy(as)}(:,r);
%     end
%  end
%
% We use more complicated code for speed only.
    
    am = nnz(As{1}) * 2;

    MR = zeros(am,1);
    MC = zeros(am,1);
    MV = zeros(am,1);
    
    MR(1) = 1;
    MC(1) = 1;
    MV(1) = 1;
       
    index = 1;
    
    for r=2:size(As{1},1)
        as = fval(r-1);
        if term(as)
            index = index + 1;
            MR(index) = r;
            MC(index) = r;
            MV(index) = 1;            
        else
            [RC,~,RV] = find(Ast{policy(as)}(:,r));
            indexStart = index + 1;
            index = index + size(RC,1);            
            MR(indexStart:index) = r*ones(size(RC,1),1);
            MC(indexStart:index) = RC;
            MV(indexStart:index) = RV;
        end
    end
    
    MR = MR(1:index);
    MC = MC(1:index);
    MV = MV(1:index);
    
    M = sparse(MR,MC,MV,size(As{1},1),size(As{1},2));
end