function MM = packP(P)
% This function adds a row and a column to the top and left of the matrix
% P. There is a one in the entry (1,1) and elsewhere the added values are
% zeros.
   MM = [1                  zeros(1,size(P,2)); ...
         zeros(size(P,1),1) P                   ];
end

