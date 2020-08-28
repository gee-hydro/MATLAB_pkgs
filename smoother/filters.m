function yfits = filters(y, w, nptperyear, iters, modweight, methods, IsPlot)
if nargin < 4 || isempty(iters), iters  = 2; end
if nargin < 5 || ~isa(modweight, 'function_handle'), modweight = ModWeights.default; end
if nargin < 6 || isempty(methods)
    methods = {'movmean', 'sgfitw', 'savgol_TSM', 'whitsmw_sm', 'whitsmw_bg','HANTS', 'HANTS2'};
end
if nargin < 7, IsPlot = true; end

%% shared parameters 
n     = length(y);

if isempty(w)    , w = ones(n, 1); end
if nptperyear > n, nptperyear = n; end
nyear = floor(n/nptperyear);

% y limits: low and up values
alpha = 0.01;
ylu   = quantile(y, [alpha/2, 1 - alpha]);
ylu   = [max(0, ylu(1)), ylu(end)];
w(y < ylu(1) | y > ylu(2)) = 0;

% handle NA values
missval = ylu(1) - diff(ylu)/10;
I_na = find(isnan(y));
y(I_na) = missval;
w(I_na) = 0;

d     = 2; %also known as order
frame = floor(nptperyear/7)*2 + 1;
wfact = 1/2;

nmethod = length(methods);
yfits   = cell(nmethod, 1);
for i = 1:nmethod
    methodI = methods{i};
    switch methodI
        case 'movmean'
            S = (-(frame-1)/2:(frame-1)/2)' .^ 0;
            yfit = sgfitw(y, w, frame, S, ylu, nptperyear, iters, modweight);
            % yfit = movmean(y, [frame, frame], 'omitnan'); %simplest movmean 
        case 'sgfitw'
            %% 01. weigthed savitzky-golay
            S = (-(frame-1)/2:(frame-1)/2)' .^ (0:d);
            [yfit, w_sg] = sgfitw(y, w, frame, S, ylu, nptperyear, iters, modweight);
        case 'savgol_TSM'
            yfit = savgol_TSM(y, y, w, frame, wfact, nptperyear, iters, modweight, false);
        case 'HANTS'
            %constrain ylu lead to nout too large
            yfit = HANTS_MultiYears(y, w, false, ylu, nptperyear, iters, modweight); 
        case 'HANTS2'
            yfit = HANTS_MultiYears(y, w, true, ylu, nptperyear, iters, modweight);
        case 'whitsmw_sm'
            % lambda = nyear * nptperyear * ifelse( nptperyear > 40, 0.2, 0.4);  
            lambda = frame * nyear/2;
            [yfit, cve, h]    = whitsmw(y, w, lambda , d, ylu, nptperyear, iters, modweight);
        case 'whitsmw_bg'
            % lambda = nyear * nptperyear * ifelse( nptperyear > 40, 0.4, 0.6);  
            lambda = frame * nyear;
%             [yfit, cve, h]    = whitsmw(y, w, lambda , d, ylu, nptperyear, iters, modweight);
            plot(y); hold on
            lambdas = 10.^(1:0.1:5);
            cvs = [];
            for lambda = lambdas
                [yfit, cv, h]   = whitsmw(y, w, lambda, d, ylu, nptperyear, iters, modweight);
                cvs = [cvs cv];
            end
            [~, I] = min(cvs);
            lamgda = lambdas(I);
            [yfit, cve, h]   = whitsmw(y, w, lambda, d, ylu, nptperyear, iters, modweight);
            
            plot(yfit)
        otherwise
            error('Invalid methods was input!')
    end
    yfits{i} = yfit;
end
yfits = cat(2, yfits{:});

if IsPlot
    y(w == 0) = nan; %remove points whose weight equal to zero.
    plot([y, yfits]) %, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'w'
%     plot([z_hant, z_hant2]);
%     plot(linspace(1, n, 4*n), z3);
    lgds = [{'Original Data'}, methods];
    legend(lgds, 'Interpreter', 'none');
    set(gca, 'xtick', 1:nptperyear:n+1, 'xlim', [1, n+1]); 
    grid on
end

yfits = array2table(yfits, 'VariableNames', methods);
