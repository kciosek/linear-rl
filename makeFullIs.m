function Is = makeFullIs(length,size)
% This function makes initiation sets that are full (i.e. all states are
% allowed in the initiation set). They are returned in the cell array Is.
% The number of initiation sets is specified in the parameter length. The
% size of each initiation set is specified in the parameter size. Since all
% initiation sets begin with a one in the first index, the parameter size
% is equal to the number of states in the MDP plus one.
    I = ones(size,1);
    Is = repmat({I},length,1);
end

