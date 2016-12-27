function M = makeGreedyModel(V,As)
% This function makes contructs a model, based on the action set specfied
% by the cell array As, and a value function specified in the vector V.
% First, for each state, an anction is chosen which is greedy wrt. the
% value function V. Then the model is exponentated to the power equal to
% the number of states.
    Mt = sparse(size(As{1},1), size(As{1},2));
    Mt(1,1) = 1;
    % For speed, it is convenient to work with transposed models.
    Ast = cellfun(@(m) m',As,'UniformOutput',false);
    Vt = V';
    for r=2:size(As{1},1)
        max_val = -realmax;
        for i=1:length(As)
            val = Vt * Ast{i}(:,r);
            if val > max_val
                Mt(:,r) = Ast{i}(:,r);
                max_val = val;
            end
        end
    end
    M = Mt';
    M = M ^ size(As{1},1);
end