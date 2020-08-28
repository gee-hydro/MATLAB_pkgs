function  y = sgfit(x, frame, d)
% function  y = weight_sgfit(x, w, frame, d)

% Compute the Vandermonde matrix
S        = (-(frame-1)/2:(frame-1)/2)' .^ (0:d);
halfwin    = (frame - 1)/2;

% [B, S]   = sg(d, frame);
% yPredict = B * X;
% n        = size(ImgCol, 1);
n          = length(x);
% y        = nan(n, 1);
% Compute QR decomposition
[Q, ~] = qr(S,0); %[Q,R]
% Compute the projection matrix B
B = Q * Q';

% if type == 2
%% second solution
y_head = B(1:halfwin+1, :) * x(1:frame);

y_mid = nan(n - frame, 1);
for i = 1:n-frame
    I = i+1:i+frame;
    y_mid(i) = B(halfwin + 1, :) * x(I);
end

y_tail = B(halfwin+2:end, :) * x(end-frame+1:end);
y = [y_head; y_mid; y_tail];
