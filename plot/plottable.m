function ha = plottable(xt, gap, margin, nvar, IsDel)
%INPUTS
%   IsDel : whether to delete redundant axes
if nargin < 2, gap = [.13 .05]; end
if nargin < 3, margin = [.05 .03, .08, .05]; end
% gap    = [gap_height, gap_width]
% margin = [top, right, bottom, left];
% marg_h = [lower, upper]
% marg_w = [left, right];
%   in:  Nh      number of axes in hight (vertical direction)
%        Nw      number of axes in width (horizontaldirection)
%        gap     gaps between the axes in normalized units (0...1)
%                   or [gap_h gap_w] for different gaps in height and width
%        marg_h  margins in height in normalized units (0...1)
%                   or [lower upper] for different lower and upper margins
%        marg_w  margins in width in normalized units (0...1)
%                   or [left right] for different left and right margins
%EXAMPLE
%   plottable(xt, [.13 .05], [.05 .03, .08, .05])
%PLOTTABLE plot function for table class
%% PLOT function for timetable or table with a date column (date vector)
% xt = inputs;
vars = xt.Properties.VariableNames;
% GEE data, date stored in 'id' column
if any(strcmp(vars, 'id'))
    xt.Properties.VariableNames{'id'} = 'date';
    vars = xt.Properties.VariableNames;
end

Id_val = cellfun(@(x) ~any(strcmp(x, {'date', 'Year', 'DOY', 'd8Id'})), vars);
% remove columns: 'date', 'Year', 'DOY', 'd8Id'
vars = vars(:, Id_val);

% figure out how many rows
if nargin < 4 || isempty(nvar), nvar = length(vars); end

ncol = ceil(sqrt(nvar));
nrow = floor((nvar - 1)/ncol) + 1;

figs = findobj(0, 'type', 'figure');
if isempty(figs), figure('pos', [200, 200, 350*ncol, 200*nrow]); end

ha = tight_subplot(nrow, ncol, gap, margin);
for i = 1:length(vars)
    axes(ha(i))
    %     row = floor((i - 1)/ncol) + 1;
    %     col = mod(i-1, ncol) + 1;
    %     subplot(nrow, ncol, i);
    plot(xt.date, eval(['xt.', vars{i}]));
    datetick('x', 'yyyy/mm')
    title(vars{i}, 'Interpreter', 'none');
end

if nargin < 5 || IsDel
    if nvar < ncol * nrow, delete(ha(nvar+1:ncol*nrow)); end
end
% axes(ha(i+1));
plotsetting;