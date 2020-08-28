function [z, cve, h] = whitsmddw(x, y, w, lambda, d, iters, IsPlot)
% Whittaker smoother with divided differences and weights
% Input:
%   x:      data series of sampling positions (must be increasing)
%   y:      data series, assumed to be sampled at equal intervals
%   w:      weights
%   lambda: smoothing parameter; large lambda gives smoother result
%   d:      order of differences (default = 2)
% Output:
%   z:      smoothed series
%   cve:    RMS leave-one-out prediction error
%   h:      diagonal of hat matrix
%
% Remark: the computation of the hat diagonal for m > 100 is experimental;
% with many missing observation it may fail.
%
% Paul Eilers, 2003
% 
% Update 25 Aug'2017, Dongdong Kong:
%   Add weight updating methods for outlier. 

% Default order of differences
if nargin < 3, w = ones(size(x)); end
if nargin < 4, lambda = 1;        end
if nargin < 5, d = 2;             end
if nargin < 6, iters = 2;         end
if nargin < 7, IsPlot = false;    end

x0 = x;
if isdatetime(x)
    x = datenum(x);
    x = x - x(1) + 1; 
end

m = length(y);
% E = speye(m);
D = ddmat(x, d);

modweights = @ModWeights.bisquare;

z = cell(iters, 1);
for i = 1:iters
    % Smoothing
    W = spdiags(w, 0, m, m);
    C = chol(W + lambda * (D' * D));
    z = C \ (C' \ (w .*y));
    
    w = modweights(y, z); %modweights(Yobs, Ypred)
    if IsPlot
        if i == 1, plot(x0, y); hold on; end
        plot(x0, z);
    end
    % Outliers has been set to a extremely low weight, so y values could
    % not been modified.
    % Validity index also need to consider different weights of different
    % points. When hav outliers, RMS leave-one-out prediction error is not
    % reliable.
end

if IsPlot
    lgds = cellfun(@(i) ['iter:', num2str(i)], num2cell(1:iters), 'UniformOutput', false);
    lgds = ['Original VI', lgds]; 
    legend(lgds);
end

% Computation of hat diagonal and cross-validation
if nargout > 1
   if m <= 100    % Exact hat diagonal
      W = diag(w);
      H = (W + lambda * D' * D) \ W;
      h = diag(H);
   else           % Map to diag(H) for n = 100
      n       = 100;
      % E1    = speye(n);
      g       = round(((1:n) - 1) * (m - 1) / (n - 1) + 1);
      D1      = ddmat(x(g), d);
      W1      = diag(w(g));
      lambda1 = lambda * (n / m) ^ (2 * d);
      H1      = inv(W1 + lambda1 * D1' * D1);
      h1      = diag(H1);
      u       = zeros(m, 1);
      k       = floor(m / 2);
      k1      = floor(n / 2);
      u(k)    = 1;
      v       = C \ (C' \ u);
      hk      = v(k);
      f       = round(((1:m)' - 1) * (n - 1)/ (m - 1) + 1);
      h       = w .* h1(f) * v(k) / h1(k1);
   end
   r   = (y - z) ./ (1 - h);
   cve = sqrt(r' * (w .* r) / sum(w));
end
