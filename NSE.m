%NSE
% Nash¨CSutcliffe model efficiency coefficient
% E = NSE(Yobs, Ysim)
%
% Inputs:
% Yobs  :observed values
% Ysim  :simulated values
function [NASH_coef, R2_coef, RMSE, pval, n] = NSE(Yobs, Ysim)

% remove NAN values in Yobs and Ysim.
%   If necessary negative values also need to remove.
I = ~(isnan(Yobs) | isnan(Ysim));
Ysim = Ysim(I);
Yobs = Yobs(I);

NASH_coef = 1 - sum((Ysim - Yobs).^2) ./ sum((Yobs - mean(Yobs)).^2);
% bias = sum(Ysim - Yobs)/sum(I);

if nargout > 1
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