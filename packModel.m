function MM = packModel(M)
% In our algoritm, models are represented as matrices of size (s+1)x(s+1)
% where s is the number of states in the MDP. This function makes such a
% matrix from the reward vector R of length s and the probability 
% transition matrix P of size s x s. These parameters are specified as 
% fields in the input cell array (i.e. they are M.R and M.P).
    MM = [1 zeros(1,size(M.P,1)); M.R M.P];
end

