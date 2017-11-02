%MATCH
%   MATCH function like R language
function Id = match(x, y)
n  = length(x);
Id = nan(n, 1);

if iscell(x)
    for i = 1:length(x)
        I = find(strcmp(x{i}, y));
        if ~isempty(I), Id(i) = I; end
    end
end

Id_x = find(~isnan(Id));
Id_y = Id(Id_x);
Id = table(Id_x, Id_y);
