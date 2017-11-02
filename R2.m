%R2 
% Determined coefficient
% R2_coef = R2(Yobs, Ysim)
% 
% Inputs:
% Yobs  :observed values
% Ysim  :simulated values
function [R2_coef, RMSE, pval] = R2(Yobs, Ysim)

% remove NAN values in Yobs and Ysim.
%   If necessary negative values also need to remove.
I = ~(isnan(Yobs) | isnan(Ysim));
Ysim = Ysim(I);
Yobs = Yobs(I);

[b,bint,r,rint,stats] = regress(Ysim, [Yobs, ones(size(Yobs))]); %#ok<ASGLU>
% [b,bint,r,rint,stats] = regress(Ysim, [Yobs, ones(size(Yobs))]); %#ok<ASGLU>
R2_coef = stats(1);
RMSE    = stats(4)^2;
pval    = stats(3);  %pvalue
% Ypred = polyval(b, Yobs);
% n = length(Yobs);
% RMSE = sqrt(sum((Ypred - Ysim).^2)/(n - 2)); 

% E = 1 - sum((Ypred - Yobs).^2) ./ sum((Ypred - mean(Yobs)).^2);
% Determined coefficient is familiar with NSE. But the meaning was
% different.