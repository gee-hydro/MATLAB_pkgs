function [bias_coef, b] = bias(Yobs, Ysim, IsPlot)

if nargin == 3 && IsPlot
    plot(Yobs, Ysim, '.'); hold on; %scatters in subplot6
    %nobs_max = sum(~isnan(Yobs) | ~isnan(Ysim));
    nobs_min = sum(~isnan(Yobs) & ~isnan(Ysim));
end

I = ~(isnan(Yobs) | isnan(Ysim));
Ysim_new = Ysim(I);
Yobs_new = Yobs(I);

if isempty(Yobs_new)
    % If no data left, then return nan;
    bias_coef = nan;
    b = nan(2, 1);
else
    bias_coef = sum(Ysim_new - Yobs_new)/sum(Yobs_new); % bias
    b         = polyfit(Yobs_new, Ysim_new, 1);   % linear regression coefficient [slope, interception]
    % slope     = b(1);                           % slope of lm
end

%% plot
if nargin == 3 && IsPlot && ~isnan(bias_coef)
    % 1. axis equal, 45deg line
    lim = [0, ceil(max(max(Yobs_new), 1))];
%     set(gca, 'xlim', lim, 'ylim', lim)
    hold on; plot(lim, lim, 'k-'); grid on
    
    % 2. line regression line
    ypred = polyval(b, Yobs_new);
    plot(Yobs_new, ypred, 'r--'); % linear regression
    
    % linear regression info
    text(0.4, 0.2, sprintf('y = %.3fx %+.3f', b),...
        'Units', 'normalized', 'FontSize',12, 'FontName','Arial');
    text(0.05, 0.8, sprintf('nobs = %d\nbias = %.3f', nobs_min, bias_coef), ...
        'Units', 'normalized', 'FontSize',12, 'FontName','Arial');
end