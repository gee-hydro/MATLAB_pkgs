
% Whittaker smoother with divided differences and weights
% Input:
%   x:      data series of sampling positions (must be increasing)
%   y:      data series, assumed to be sampled at equal intervals
%   w:      weights
%   lambda: smoothing parameter; large lambda gives smoother result
%   d:      order of differences (default = 2)
% Output:
%   z:      smoothed series
%   cve:    RMS leave-one-out prediction error
%   h:      diagonal of hat matrix
%
% Remark: the computation of the hat diagonal for m > 100 is experimental;
% with many missing observation it may fail.

[z, cve, h] = whitsm(y, lambda, d)
[z, cve, h] = whitsmw(y, w, lambda, d)
 
[z, cve, h] = whitsmdd(x, y, lambda, d)
[z, cve, h] = whitsmddw(x, y, w, lambda, d)   %optimal method


[z cve, h] = whitsm(y(1:230), lambda, 3);
sum(h)
