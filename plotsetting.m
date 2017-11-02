%% set plots fontsize, fontfamily, linewidths using handle.
function plotsetting(xlab, ylab)
    %% set plots fontsize, fontfamily, linewidths using handle.
    axes_hl = findobj(0, 'type', 'axes');
    font = 'Times New Roman';%'微软雅黑';
    set(axes_hl, 'fontsize', 10, ... %'fontname', font, ...
        'xgrid', 'on', 'ygrid', 'on', ...
        'XMinorGrid', 'off','YMinorGrid', 'off')
    
    if nargin == 0
        xlab = []; %'Evaporation (mm)'
        ylab = []; %'mm/d';
    end
    % ylab = 'LAI' ; %'Evaporation (mm)'

    if ~isempty(xlab) && ischar(xlab)
        arrayfun(@(axes) set(get(axes, 'xlabel'), 'string', xlab), axes_hl)
    end
    if ~isempty(ylab) && ischar(ylab)
        arrayfun(@(axes) set(get(axes, 'ylabel'), 'string', ylab), axes_hl)
    end
    
    line_hl = findobj(0, 'type', 'line');
    set(line_hl, 'linewidth', 1)
end