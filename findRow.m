function [b,c]=findRow(x,searchfor)
% This function takes two paramters: a sorted array x and the value
% searchfor. It return the beginning and ending indices b and c. The point
% to where elements equal to searchfor begin and end in the array x.
% Courtesy of Daniel R.
% http://stackoverflow.com/questions/20166847
    a=1;
    b=numel(x);
    c=1;
    d=numel(x);
    while (a+1<b||c+1<d)
        lw=(floor((a+b)/2));
        if (x(lw)<searchfor)
            a=lw;
        else
            b=lw;
        end
        lw=(floor((c+d)/2));
        if (x(lw)<=searchfor)
            c=lw;
        else
            d=lw;
        end
    end
end
