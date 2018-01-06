% Usage:
%   vargout = ifelse(con, a, b)
%   If condition is true, then return a, otherwise return b;
function vargout = ifelse(con, a, b)
if con
    vargout = a;
else
    vargout = b;
end
