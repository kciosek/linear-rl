function V = plainValueIteration( As , Is )
% This function implements the plain value iteration algorithm. Unlike the
% othe algorithms in this software, this one does not iterate matrix
% transition models - instead, it works only with vectors representing the
% value function of the MDP.
% The argument As is a cell array containing action models.
% The optional argument Is is a cell array containing the initiation sets.
% The retrun value V is a vector containing one in the first entry,
% followed by the optimum value function of the MDP.
    if nargin < 2
        Is = makeFullIs(length(As),size(As{1},1));
    end

    n = size(As{1},1);
    V = [1, zeros(1,n-1)];
    
    % We work with transposed models because it is faster.
    Ast= cellfun(@(m) m',As,'UniformOutput',false);
    
    fprintf('Iteration: ');    
    iter = 1;
    
    while(true)
        fprintf('%d ', iter);
        
        % We work with horizontal vectors because models are transposed.
        Vnew = [1, ones(1,n-1) * -realmax];
        for ai=1:length(As)
            % Compute the indexes of the states in the initiation set.
            ii = find(Is{ai});
            
            action = Ast{ai};
            for i=2:length(ii)        
                r = ii(i);
                % Equivalent to As{ai}(r,:) * V'
                vn =  V * action(:,r);
                
                % Select the action with the biggest value.
                if vn > Vnew(r)
                    Vnew(r) = vn;
                end
            end
        end
        
        if (norm(Vnew - V) < 0.001)
            break;
        end
        
        V = Vnew;
        iter = iter + 1;
    end
    
    fprintf('done.\n');
    V = V';
end

