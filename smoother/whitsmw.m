function [z, cve, h] = whitsmw(y, w, lambda, d, ylu, nptperyear, iters, modweight)
% Whittaker smoother with weights
% Input:
%   y:      data series, sampled at equal intervals 
%           (arbitrary values allowed when missing, but not NaN!)
%   w:      weights (0/1 for missing/non-missing data)
%   lambda: smoothing parameter; large lambda gives smoother result
%   d:      order of differences (default = 2)
%   iters:  iters
%   modweights: weights update function
% Output:
%   z:      smoothed series
%   cve:    RMS leave-one-out prediction error
%   h:      diagonal of hat matrix
%
% Remark: the computation of the hat diagonal for m > 100 is experimental;
% with many missing observation it may fail.
%
% Paul Eilers, 2003

% Default order of differences
if nargin < 3, lambda = 2; end
if nargin < 4, d      = 2; end
if nargin < 6 || isempty(iters) , iters  = 2; end
if nargin < 8 || ~isa(modweight, 'function_handle'), modweight = ModWeights.default; end
% Smoothing
m = length(y);
E = speye(m);
D = diff(E, d);

for i = 1:iters
    % Smoothing
    W = spdiags(w, 0, m, m);
    mat_left = full(W + lambda * (D' * D));
    rank(mat_left)
    %% second 
    W = spdiags(ones(size(w)), 0, m, m);
    mat_left = full(W + lambda * (D' * D));
    rank(mat_left)
    
    C = chol(mat_left);
    z = C \ (C' \ (w .*y));
    
    % w = modweights(y, z, w); %modweights(Yobs, Ypred)
    wfact = 0.5;
%     z = checkfit(ylu, z)';
    w = modweight(y, z, w, wfact, i, nptperyear);

    % y = z; % whether to update the value of y?
    %
    % Outliers has been set to a extremely low weight, so y values could
    % not been modified.
    % Validity index also need to consider different weights of different
    % points. When hav outliers, RMS leave-one-out prediction error is not
    % reliable.
end

% Computation of hat diagonal and cross-validation
if nargout > 1
   if m <= 100    % Exact hat diagonal
      H = W / (W + lambda * D' * D); % A * inv(x) = A / x
      h = diag(H);
      
   else           % Map to diag(H) for n = 100
      n  = 100;
      E1 = eye(n);
      D1 = diff(E1, d);
      lambda1 = lambda * (n / m) ^ (2 * d);
      g    = round(((1:n) - 1) * (m - 1) / (n - 1) + 1);
      W1   = diag(w(g));
      H1   = inv(W1 + lambda1 * D1' * D1);
      h1   = diag(H1);
      u    = zeros(m, 1);
      k    = floor(m / 2);
      k1   = floor(n / 2);
      u(k) = 1;
      v    = C \ (C' \ u);
      hk   = v(k);
      f    = round(((1:m)' - 1) * (n - 1)/ (m - 1) + 1);
      h    = w .* h1(f) * v(k) / h1(k1);
   end
   r = (y - z) ./ (1 - h); %Eq. 28, Paul H. C. Eifers, 1996
   cve = sqrt(r' * (r .* w) / sum(w));
end



