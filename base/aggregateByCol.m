%% aggregate Y values through fun by x separator
% x = readtable('data/dates_MODIS.txt', 'delimiter', '\t');
% x [ntime, 1] should be column vector
% y [ngrid, ntime]

function [xcon, yagg, yidxagg] = aggregate_Col(x, y, fun)

if ~isequal(size(x,1), size(y,2))
    error('x and y must have same SIZE!');
end

if nargin > 2
    applyfun = true;
else
    applyfun = false;
end

[xcon, ~, ix] = unique(x);

nrow = max(ix);
yrow = (1:size(x,1))';
yidxagg = accumarray(ix, yrow, [nrow 1], @(x) {x});

yagg = cell(size(yidxagg));

for iy = 1:length(yagg)
    if applyfun
        yagg{iy} = fun(y(:, yidxagg{iy}));
    else
        yagg{iy} = y(:, yidxagg{iy});
    end 
end
