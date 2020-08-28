function yfits = savgol_TSM(y, yt, w, frame, wfact, nptperyear, iters, modweight, print)
%TIMESAT SAVGOL Savitzky-Golay Filtering.
%   yfits = SAVGOL(y, yt, w, nenvi, wfact, ~, frame) smoothes the signal X using a
%   Savitzky-Golay (polynomial) smoothing filter.  The polynomial order,
%   ORDER, must be less than the frame length, FRAMELEN, and FRAMELEN must
%   be odd.  The length of the input X must be >= FRAMELEN.  If X is a
%   matrix, the filtering is done on the columns of X.
%
%Inputs
%   y     : original VI time-series
%   yt    : trend of y, returned by stl
%           [rw, yseason, ytrend] = stl_mex(ystlin, npt, nptperyear, STLstiffness);
%   w     : weightings
%   nenvi : No. of Envelope iterations
%   wfact : strength of envelope adaptation
%   frame   : window size of SG. frame = 2*frame +1;
%
%   npt   : length of y
% coder.varsize('y', 'yt', 'w', [1, 1000]);
% global print
if nargin < 7, iters = 2    ; end
if nargin < 8 || ~isa(modweight, 'function_handle'), modweight = ModWeights.default; end
if nargin < 9, print = false; end

npt = length(y);

if frame == 0
    yfits = y;
    return
end

winmax = max(frame);

t    =  (- winmax + 1:npt + winmax)';
wfit = [w(npt - winmax + 1:npt); w; w(1:winmax)];
y    = [(y(npt - winmax + 1:npt) + yt(1) - yt(npt)); y; (y(1:winmax) + yt(npt) - yt(1))];
yfit = y;

for j = 1:iters
    yfitmean   = sum(yfit .* ceil(wfit)) / sum(wfit > 0);
    yfitstd    = sqrt(sum(((yfit - yfitmean) .* ceil(wfit)) .^ 2) / (sum(wfit > 0) - 1));
    y_critical = 1.2 * 2 * yfitstd;
    for i = winmax + 1:npt + winmax
        m1 = i - frame;
        m2 = i + frame;
        
        if (max(yfit(m1:m2)) - min(yfit(m1:m2)) > y_critical)
            m1 = m1 + floor(frame / 3);
            m2 = m2 - floor(frame / 3);
        end
        
        % if less than 3 points at left or right, then extend it
        failleft = 0;
        while sum(abs(wfit(m1:i)) > 1e-10) < 3
            m1 = m1 - 1;
            if m1 < 1
                failleft = 1;
                m1 = 1;
                break;
            end
        end
        
        failright = 0;
        while sum(abs(wfit(i:m2)) > 1e-10) < 3
            m2 = m2 + 1;
            if m2 > npt + 2 * winmax
                failright = 1;
                m2 = npt + 2 * winmax;
                break;
            end
        end
        
        if failleft == 0 && failright == 0
            frmlen = m2 - m1 + 1;
            % A = wfit(m1:m2) .* [ones(frmlen, 1), t(1:frmlen), t(1:frmlen).^2];
            wi = wfit(m1:m2);
            X  = ( t(1:frmlen) .^ (0:2) );
            A  = wi .* X;
            b  = wi .* y(m1:m2);
            c  = A\b;
%             W  = diag(wi);
%             Y  = y(m1:m2);
%             c  = (X' * W * X) \ (X' * W * Y)
%             c  = (W * X) \ (W * Y);
            yfit(i) = c(1) + c(2) * t(i - m1 + 1) + c(3) * t(i - m1 + 1) ^ 2;
            
            % kongdd Modified
%             X = wfit(m1:m2) .* t(1:m2 - m1 + 1);
%             Y = wfit(m1:m2) .* y(m1:m2);
%             p = polyfit(X, Y, 2);
%             yfit(i) = polyval(p, t(i - m1 + 1));
        else
            yfit(i) = median(y(m1:m2));
        end
    end
    yfit(yfit < 0) = 0; % Just designed for flux-sites of MOD15A2 LAI & FPAR data
    
    if print == 1
        lcn = 'northeast'; %'best'
        % wmax = max(wfit);
        if j == 1
            % figure(4 + j)
            plot(y(winmax + 1:npt + winmax))
            hold on
            %             xlabel('time'), ylabel('sensor data')
            %             xlim([1, npt])
        end
        
        plot(yfit(winmax + 1:npt + winmax))
        
        if j == iters
            lgds = cellfun(@(i) ['iter:', num2str(i)], num2cell(1:iters), 'UniformOutput', false);
            lgds = ['Original VI', lgds]; %#ok<AGROW>
            legend(lgds, 'location', lcn);
        end
        %         title(sprintf('Savitzky-Golay, position %u %u'))
        %         pause
    end
    
    if j < iters
        wfit = modweight(y, yfit, wfit, wfact, j, nptperyear);
    end
end

yfits = yfit(winmax + 1:npt + winmax);