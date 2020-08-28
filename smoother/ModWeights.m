classdef ModWeights
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    % ModWeights.default;
    properties (Constant)
        default=@ModWeights.TSM; % bisquare, TSM, TSM2
    end
    
    methods (Static)
        %MODWEIGHT modify weights of curve fitting methods
        %   pars = {wfit, wfact, iter};
        %   wmod = ModWeights.TSM(y, yfit, pars)
        %   
        %DESCRIPTION
        %   The updating weights strategy was not so reasonable.
        %   And have no reference value.
        %
        %Inputs
        %   y       : original VI time-series
        %   yfit    : values after curve fitting
        %   pars    : {wfit, wfact, iter}; 
        %   --------:---------------------------
        %   wfit    : weights of VI points
        %   wfact   : strength of envelope adaptation
        %   iter    : iter
        %
        %Outputs
        %   wmod    : weights after modified
        %
        %Update:
        %   Dongdong Kong, 31 July'2017
        %
        %Locally weighted linear regression was used here.
        %   http://blog.csdn.net/houlaizhexq/article/details/27706477
        %   http://blog.csdn.net/u013802188/article/details/40187459
        function wmod = TSM(y, yfit, wfit, varargin)
            % wfact = 1/2; %TSM default value
            wfact = varargin{1};
            iter  = varargin{2};
            nptperyear = varargin{3};
            
            n = length(yfit);
            
            % NA values' weightings have been set to zero.
            %   So, the following mean and std calculate was
            yfitmean = sum(yfit .* ceil(wfit)) / sum(wfit > 0);
            yfitstd  = sqrt(sum(((yfit - yfitmean) .* ceil(wfit)) .^ 2) / (sum(wfit > 0) - 1));
            critical = 0.4 * 2 * yfitstd;
            
            % modified 19 Dec' 2017
            % 1. give constrain for ungrowing season spike values
            wmod = wfit;
            for i = 1:n
                m1 = max(1, i - floor(nptperyear / 7)); % begin of window
                m2 = min(n, i + floor(nptperyear / 7)); % end of window
                % only reduce the weighting of overestimated points
                % !---- Modify weights of all points in the first iteration. After that ----------
                % !     only weights of high points are modified
                if (yfit(i) - y(i) > 1e-8)
                    % !---- If there is a low variation in an interval, i.e. if the interval
                    % !     is at a peak or at a minima compute the normalized distance
                    % !     between the data point and the fitted point
                    if min(yfit(m1:m2)) > yfitmean || iter < 2 
                        % points at growing seasons
                        % have some flaw
                        if max(yfit(m1:m2)) - min(yfit(m1:m2)) < critical
                            ydiff = 2 * (yfit(i) - y(i)) / yfitstd;
                        else
                            ydiff = 0;
                        end
                        wmod(i) = wfact * wfit(i) * exp( - ydiff ^ 2);
                    end
                end
            end
        end
        
        %TSM2 modify weights of curve fitting methods coded in matrix format
        %   wmod = TSM2(y, yfit, varargin)
        %   varargin = {wfit, wfact, iter};
        function wmod = TSM2(y, yfit, wfit, varargin)
            % wfact = 1/2; %TSM default value
            wfact = varargin{1};
            iter  = varargin{2};
            nptperyear = varargin{3};
            
            % n        = length(yfit);
            yfitmean = sum(yfit .* ceil(wfit)) / sum(wfit > 0);
            yfitstd  = sqrt(sum(((yfit - yfitmean) .* ceil(wfit)) .^ 2) / (sum(wfit > 0) - 1));
            critical = 0.4 * 2 * yfitstd;
            
            wmod     = wfit;
            framelen = floor(nptperyear/7) * 2 + 1; %half window width of moving window
            
            yfit_movmin = movmin(yfit, framelen, 'omitnan'); %since 2016a
            yfit_movmax = movmax(yfit, framelen, 'omitnan');
            
            dif = yfit - y;
            
            % 1. weights overestimated values were reduced here. Others are remained as Input.
            Id1 = dif > 1e-8;
            % 2. points where moving min < yMean or iter < 2
            Id2 = yfit_movmin > yfitmean | iter < 2;
            % 3. In the Peak of growing season
            Id3 = yfit_movmax - yfit_movmin  < critical;
            
            % fprintf('Critical value: %f\n', critical)
            Index = find(Id1 & Id2);
            
            for i = 1:length(Index)
                I = Index(i);
                if Id3(I)
                    ydiff = 2 * dif(I) / yfitstd;
                else
                    ydiff = 0;
                end
                %     wmod(i) = wfact * wfit(i) * exp( - ydiff ^ 2);
                wmod(I) = wfact * wfit(I) * exp( - ydiff^2);
            end
            % fprintf('J = %d\n', j)
            
            debug = true;
            if debug
                % only show weights have changed.
                I = find(Id1 & Id2);
                
                figure
                subplot(211)
                
                plot(y, '-b'); hold on
                plot(yfit, '-r')
                plot(yfit_movmax)
                plot(yfit_movmin)
                plot(yfit_movmax - yfit_movmin, 'linewidth', 1.5)
                plot([0, 360], yfitmean*[1, 1], 'b--')
                plot([0, 360], critical*[1, 1], 'r--')
                
                plot(I, y(I),    'bs', 'MarkerSize', 5)
                plot(I, yfit(I), 'ro', 'MarkerSize', 5)
                legend('original VI', 'curve fitting VI', ...
                    'movmax', 'movmin', 'movmax - movmin', ...
                    'yfitmean', 'critical')
                xlim([0, 360])
                grid on
                
                subplot(212)
                %     plot(wfit, '+'), hold on
                %     plot(wmod, '*')
                plot(I, wfit(I), 'bs'), hold on
                plot(I, wmod(I), 'ro')
                legend('original weights', 'Modified weights')
                xlim([0, 360])
                grid on
            end
        end
        
        function w = bisquare(Yobs, Ypred, varargin)
            %MODWEIGHTS modified weights of each points according to residual
            %   w = modweights(Yobs, Ypred)
            %@description:
            %   Suggest to replaced NA values with a fixed number such as -99.
            %   Otherwise, it will introduce a large number of missing values in
            %   fitting result, for lowess, moving average, whittaker smoother and
            %   Savitzky-Golay filter.
            %% 1. robust weights are given by the bisquare function like lowess function
            %  Reference: https://cn.mathworks.com/help/curvefit/smoothing-data.html#bq_6ys3-3
            re = abs(Yobs - Ypred); %residual
            sc = 6 * nanmedian(re);    %overall scale estimate
            
            w = zeros(size(re));
            w(re < sc) = ( 1 - ( re(re < sc) / sc ).^2 ).^2; %NA values weighting will be zero
        end
        
    end
    
end
