%NSE
% Nash¨CSutcliffe model efficiency coefficient
% E = NSE(Yobs, Ysim)
%
% Inputs:
% Yobs  :observed values
% Ysim  :simulated values
function [NASH_coef, R2_coef, RMSE, pval, n] = NSE(Yobs, Ysim, IsPlot)

% remove NAN values in Yobs and Ysim.
%   If necessary negative values also need to remove.
I = ~(isnan(Yobs) | isnan(Ysim));
Ysim = Ysim(I);
Yobs = Yobs(I);

NASH_coef = 1 - sum((Ysim - Yobs).^2) ./ sum((Yobs - mean(Yobs)).^2);
% bias = sum(Ysim - Yobs)/sum(I);

if nargout > 1 || (nargin == 3 && IsPlot)
    [b,bint,r,rint,stats] = regress(Ysim, [Yobs, ones(size(Yobs))]); %#ok<ASGLU>
    % [b,bint,r,rint,stats] = regress(Ysim, [Yobs, ones(size(Yobs))]); %#ok<ASGLU>
    R2_coef = stats(1);
    RMSE    = stats(4)^2;
    pval    = stats(3);  % pvalue
    n       = length(I); % length of validate obs
end
% E = 1 - sum((Ypred - Yobs).^2) ./ sum((Ypred - mean(Yobs)).^2);
% Determined coefficient is familiar with NSE. But the meaning was
% different.

if nargin == 3 && IsPlot
    bias_coef = bias(Yobs, Ysim);
    nobs = sum(I);
    scatter(Yobs, Ysim, [], 'filled', 'MarkerFaceAlpha',1/20, ...
        'MarkerFaceColor', [0.4940    0.1840    0.5560]);
    hold on; grid on; box on
    % 45deg line
    lim = [0, ceil(max(max(Yobs), 1))];
    set(gca, 'xlim', lim, 'ylim', lim)
    plot(lim, lim, 'k-'); 
    % statistic info
    text( 0.05, 0.85, sprintf('NSE = %4.3f, R^2 = %4.3f\nBias = %4.1f%%, n = %4d\nRMSE = %4.3f', ...
        NASH_coef, R2_coef, bias_coef*100, nobs, RMSE), ...
        'Units', 'normalized', 'FontSize',12, 'FontName','Arial');
end