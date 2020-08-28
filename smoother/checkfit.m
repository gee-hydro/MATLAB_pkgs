% CHECKFIT check whether y values in the boundary of ylu. If not used linear
%  interpolation to replace it, according to nearest points.
%
% yInterp = CHECKFIT(ylu, y)
% Inputs
%   ylu: [ymin, ymax]
%   y:   row vector of size [1, ncol]
function yInterp = checkfit(ylu, y)
n = length(y);
yInterp = y;
I_nan   = y < ylu(1) | y > ylu(2);

% I rewrite the kenal script of checkFit, in this way, this function's
%   perfermance will promote a lot. kongdd, 2017-06-17
if sum(I_nan) > 0
    if sum(I_nan) == n, return, end %If all is nan, then return.
    y(I_nan) = nan;
    t = 1:n;
    
    % fixed 19 Dec, 2017; linear interpolation will introduce new outlier.
    yInterp = interp1(t(~I_nan), y(~I_nan), t, 'nearest', 'extrap');
    
    % If still have nan values in tail or head, then replace nan values
    %   according to nearest point.
    if sum(isnan(yInterp)) > 0
        Id_Nnan = find(~isnan(yInterp));
        iBegin = Id_Nnan(1);
        iEnd = Id_Nnan(end);
        
        if iBegin > 1, yInterp(1:iBegin) = y(iBegin); end
        if iEnd < n,   yInterp(iEnd:n) = y(iEnd); end
    end
end

yInterp = yInterp(:)';
% for i = 1:npt
%     if y(i) < ylu(1) || y(i) > ylu(2)
%         nleft = 0; nright = 0;
%         for j = i: - 1:1
%             if ylu(1) <= y(j) && y(j) <= ylu(2)
%                 %                 yleft = y(j);
%                 nleft = j;
%                 break
%             end
%         end
%         
%         for j = i+1:npt
%             if ylu(1) <= y(j) && y(j) <= ylu(2)
%                 %                 yright = y(j);
%                 nright = j;
%                 break
%             end
%         end
%         
%         if nleft == 0 && nright == 0
%             break
%         end
%         
%         if nleft == 0
%             y1(i) = y(nright);
%         elseif nright == 0
%             y1(i) = y(nleft);
%         else
%             k = (y(nright) - y(nleft)) / (nright - nleft);
%             y1(i) = y(nleft) + k * (i - nleft);
%         end
%     end
% end
