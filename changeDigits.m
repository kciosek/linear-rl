function r = changeDigits(v, map, len)
% This function hanges the decimal digits of the value specified in v
% according to the map given in the parameter map. The number of digits is
% given in the paramter len.
% The map is given in the format:
% [f(0) f(1) f(2) ... f(9)]
   r = 0;
   for i=1:len
       digit = mod(v,10);       
       newDigit = map(digit + 1);
       r = r + 10^(i-1) * newDigit;
       v = floor(v / 10);
   end
end

