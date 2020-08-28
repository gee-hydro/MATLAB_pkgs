function ans = existVAR(INPUTS, varname)
% judge whether varname in the variable names of xt

if isstruct(INPUTS)
    varnames = fieldnames(INPUTS);
elseif istable(INPUTS)
    varnames =  INPUTS.Properties.VariableNames;
end

ans = any(strcmp(varname, varnames));