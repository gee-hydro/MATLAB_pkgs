% weighted savitzky-golay fit
function  [z, w] = sgfitw(y, w, frame, S, ylu, nptperyear, iters, modweight)
% Input:
%   y:      data series, sampled at equal intervals 
%           (arbitrary values allowed when missing, but not NaN!)
%   w:      weights (0/1 for missing/non-missing data)
%   frame:  moving window size
%   S:      
%   iters:  iters
%   modweight: weights update function
% function  y = weight_sgfit(x, w, frame, d)
if nargin < 6 || isempty(iters), iters  = 1; end
if nargin < 7 || ~isa(modweight, 'function_handle'), modweight = ModWeights.default; end

% Compute the Vandermonde matrix
% S = (-(frame-1)/2:(frame-1)/2)' .^ (0:d);
halfwin = floor((frame - 1)/2); %make true its integer

% [B, S]   = sg(d, frame);
% yPredict = B * X;
% n        = size(ImgCol, 1);
n          = length(y);
% y        = nan(n, 1);
% if type == 2
%% second solution
% figure, plot(y); hold on
for k = 1:iters
    B = sgolay(S, w(1:frame)); %[B, G]
    y_head = B(1:halfwin+1, :) * y(1:frame);
    
    y_mid = nan(n - frame, 1);
    for i = 1:n-frame
        I = i+1:i+frame;
        B = sgolay(S, w(I));
        y_mid(i) = B(halfwin + 1, :) * y(I);
    end
    
    B = sgolay(S, w(end-frame+1:end)); %[B, G]
    y_tail = B(halfwin+2:end, :) * y(end-frame+1:end);
    
    z = [y_head; y_mid; y_tail];
    z = checkfit(ylu, z)';
    % z(z < ylu(1) | z > ylu(2)) = nan;
%     plot(z);
    wfact = 0.5;
    w = modweight(y, z, w, wfact, k, nptperyear);
end
% elseif type == 1
%% first solution
%     for j = 1:n
%         if j <= halfwin
%             I = 1:frame;
%         elseif j >= n - halfwin + 1
%             I = n - frame + 1:n;
%         else
%             I = j - halfwin:j+halfwin;
%         end
%         xi = x(I);
%         wi = w(I);
%         B = sgolay(S, wi); %[B, G]
%
%         if j <= halfwin
%             bi = B(j, :);
%         elseif  j >= n - halfwin + 1
%             bi = B(j - (n - frame), :);
%         else
%             bi = B(halfwin + 1, :);
%         end
%         y(j) = bi * xi;
%     end
% end

function [B, G] = sgolay(S, weights)
% Inputs:
%   weights: column vector
% if isempty(weights)
%     % Compute QR decomposition
%     [Q,R] = qr(S,0);
%     % Compute the projection matrix B
%     B = Q*Q';
%
%     if nargout==2
%         % Find the matrix of differentiators
%         G = Q/R';
%     end
% else
%   W = diag(weights);
%   B = S * (inv(S' * W * S) * S' * W); It's also OK. used this
% Compute QR decomposition with optional weight
[~,R] = qr(sqrt(weights).*S,0);

% Compute the projection matrix B
if nargout==2
    % Find the matrix of differentiators
    G = S/(R'*R);
    % Compute the projection matrix B
    B = G*S';
    % i = floor((frameLen + 1)/2)
    % Bi = G(i, :) * S'; % row vector
    % Bi = G(:, 1)';     % Steady
else
    % Compute the projection matrix B
    T = S/R;
    B = T*T';
    % Bi = T(i, :) * T';
end
B = weights'.*B;

% /**
%  * sgolay calculate B matrix
%  *
%  * Due to weights of every points are different. So the B matrix of every points
%  * also varies.
%  * ----------------------------------------------------------------------
%  * solution 1: W = diag(w); B = S * (S'WS)^-1 * S' *W
%  * solution 2: Q * R = qr(sqrt(w) .* S); T = S/R; B = T * T' .* w
%  * The second solution only cost half time of solution 1, but still need 1 hour.
%  * Test by 4 year 4-day LAI data clipped by 212 fluxsite points.
%  *
%  * @param w: weights for different points
%  * @param S: S matrix [frame, order + 1]
%  * @return {Array} B [frame, frame]
%  */
% function sgolayB(w, S, order) {
%     S = ee.Image(S);
%     var W = w.matrixToDiag(); //inverse: matrixDiagonal
%     // print('W', W);
%     // solution 1:
%     var B = S.matrixMultiply(
%         S.matrixTranspose().matrixMultiply(W).matrixMultiply(S)
%         .matrixInverse()
%         .matrixMultiply(S.matrixTranspose()).matrixMultiply(W));
%     return B;
% }
%
% function sgolayB_qr(w, S, order){
%     S = ee.Image(S);
%     // solution 2:
%     var W = w.matrixToDiag(); //inverse: matrixDiagonal
%     var W_sqrt = w.sqrt().matrixToDiag();
%     var R = W_sqrt.matrixMultiply(S).matrixQRDecomposition().select(['R']);
%     //.get("R"); //bands named 'Q' and 'R'.
%     R = R.arraySlice(0, 0, order + 1); //get the economic R like MATLAB
%     // print('R', R);
%     // Map.addLayer(R, {}, 'R');
%
%     var T = S.matrixMultiply(R.matrixInverse()); //R is square matrix, simple Inv was enough
%     var B = T.matrixMultiply(T.matrixTranspose()).matrixMultiply(W);
%     // print('W_sqrt', W_sqrt, 'R', R, 'T', T);
%     return B;
% }