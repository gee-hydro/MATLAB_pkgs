%% Construct structure from variables like `table` function.
%   Writed By Dongdong Kong, 2017-05-12
% Description:
%   Guess structure field names through input parameter variables. So the
%   input parameters should be declared variables, and can't be temperorary
%   varibles like 1:100 et al.
% Example:
%   ngrid       = 71;
%   n_time      = 816  
%   nptPerYear  = 24;
%   x           = struct_Init(ngrid, n_time, nptPerYear);
%
function x = struct_Init(varargin)

fieldNames  = cell(nargin, 1);
x = struct();
for i = 1: nargin
    field = inputname(i);
    fieldNames{i} = field;
    % cmd = sprintf('x.%s = varargin{i};', field);
    eval(sprintf('x.%s = varargin{i};', field));
end