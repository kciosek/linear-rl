function Gp = packSubgoal(G)
% Subgoals are represented as vertical vectors. To facilitate an easier
% formulation of the algorithm, it is convenient to have a one appended on
% the top of the vectors. This way, you can multiply a model with the
% subgoal.
% The input parameter is a vector specifying the subgoal value for each
% state in the MDP. The function then appends one.
    Gp = [1; G];
end

