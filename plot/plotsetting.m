%% set plots fontsize, fontfamily, linewidths using handle.
function plotsetting(xlab, ylab, axs)
    %% set plots fontsize, fontfamily, linewidths using handle.
    if nargin >= 3
        axes_hl= axs;
    else
        axes_hl = findobj(0, 'type', 'axes');
    end
    
    % font = 'Times New Roman';%
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
    set(line_hl(1:end-1), 'linewidth', 1.2)
    box on
end