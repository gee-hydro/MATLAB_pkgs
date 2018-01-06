function runningId(i, step)

if nargin < 2, step = 1; end
if mod(i, step) == 0
    fprintf('running %d ...\n', i);
end