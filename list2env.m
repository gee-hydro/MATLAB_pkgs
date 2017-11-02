function list2env(lst)
%LIST2ENV
%   LIST2ENV(lst) lst could be 'struct' or 'table' variable.
%   Import every variables in lst into 'caller' environment.
%
%   Authors: Dongdong Kong, 2017-08-07
vars = lst.Properties.VariableNames;

for i = 1:length(vars)
    val = eval(sprintf('lst.%s', vars{i}));
    assignin('caller', vars{i}, val);
%     evalin('caller', sprintf('%s = lst.%s;', vars{i}, vars{i}));
end

% clear(lst.Properties.VariableNames{:})
% clear(fieldnames(lst)); % also works for 'table' and 'struct' variable