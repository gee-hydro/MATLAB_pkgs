function result = cut_levels(data, breaks, showQuantile, includeLowest)
% breaks = [-.05, -.02, -.01, .01, .02];
if nargin == 3 && showQuantile
%     qval = [0.95, 0.9, .75, .5, .25, .1, 0.05];
%     fprintf('\t%2dth\t', qval*100);fprintf('\n')
%     fprintf('\t%.3f\t', quantile(data(:), qval));fprintf('\n')
%     fprintf('-----------------------------------------------------------\n')
end
if nargin < 4, includeLowest = true; end

result = nan(size(data));
nc = length(breaks);

for i = 1 : nc + 1
    if includeLowest
        % include smallest
        if i == 1
            index = find(data <= breaks(i));
        elseif i == nc + 1
            index = find(data > breaks(i - 1));
        else
            index = find(data > breaks(i-1) &  data <= breaks(i));
        end
    else
        % include Biggest
        if i == 1
            index = find(data < breaks(i));
        elseif i == nc + 1
            index = find(data >= breaks(i - 1));
        else
            index = find(data >= breaks(i-1) &  data < breaks(i));
        end
    end
    
    if isempty(index); continue; end
    result(index) = i;
end

