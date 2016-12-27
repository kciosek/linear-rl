function D = generateD( Phi )
% This matrix generates the disaggregation matrix D from the aggregation
% matrix Phi. The diaggregation matrix is the normalized version of the
% transpose of Phi.
    D = Phi;
    DS = 1 ./ sum(D);
    aggrStates = size(D,2);
    scale = sparse(1:aggrStates,1:aggrStates,DS,aggrStates,aggrStates);
    D = D * scale;    
    D = D';
end

