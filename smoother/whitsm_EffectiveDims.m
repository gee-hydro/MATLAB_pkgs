function eds = whitsm_EffectiveDims(n, d, lambdas)
% Calculate the effective dimensions of Whittaker smoother
% Input:
%   x:      data series of sampling positions (must be increasing)
%   y:      data series, assumed to be sampled at equal intervals
%   lambda: smoothing parameter; large lambda gives smoother result
%   d:      order of differences (default = 2)
% Output:
%   h:      diagonal of hat matrix
%
% Dongdong Kong, 2017

% n = 46 * 5;
% d = 3;
E = speye(n);
D = diff(E, d);

len = length(lambdas);
eds = nan(len, 1);

% when having weights, this may change.
for i = 1:len
    lambda = lambdas(i);
    H = inv(E + lambda * D' * D); %#ok<MHERM>
    eds(i) = trace(H);
    % ed = sum(diag(H));
end

E  = speye(n);
D  = diff(E, d);
H  = inv(E + lambda * D' * D); 
ed = trace(H);
