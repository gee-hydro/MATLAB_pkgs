function runningId(i, step, str)

if nargin < 2, step = 1 ; end
if nargin < 3, str  = ''; end

if mod(i, step) == 0
    fprintf('running %d| %s ...\n', i, str);
end