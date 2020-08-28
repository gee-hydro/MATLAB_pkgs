% INPUTS:
% ------------------------------------------------------------------------------
% y           : Column vector of VI time-series (e.g. NDVI values)
% w           : weights of every points in y. If IsUpdatingW = false, w will be ignore.
% IsUpdatingW : true of false. If true, updating weights HANTS will be used; If false,
%               It's the traditional ones.
% 
% @CopyRight:
%   Dongdong Kong,  kongdd@mail2.sysu.edu.cn
function yfit = HANTS_MultiYears(y, w, IsUpdatingW, ylu, nptperyear, iters, modweight)
n         = length(y);
nyear     = ceil(n/nptperyear);
half_year = floor(nptperyear/2);

nf      = 3;   % fourier frequencies number
fet     = range(ylu)/10; % Fit Error Tolerance (FET)
noutmax = floor(nptperyear * 0.4);
delta   = 0;%range(ylims)/10;

yfit  = cell(nyear, 1);

%% for HANTS suggest to use the weights of weighted savitzky-golay
if IsUpdatingW
    d     = 2; %also known as order
    frame = floor(nptperyear/7)*2 + 1;
    wfact = 1/2;
    S = (-(frame-1)/2:(frame-1)/2)' .^ (0:d);
    [~, w_sg] = sgfitw(y, w, frame, S, ylu, nptperyear, iters, modweight);
end

% select the appropriate nf
% for nf = 1:5
%     runningId(nf);
for i = 1:nyear
    % previous 6 months, and afterwards 6 months were included
    iBegin = (i - 1)*nptperyear - half_year + 1;
    iEnd   = i*nptperyear + half_year;
    
    if i == 1    , iBegin = 1; end
    if i == nyear, iEnd   = n; end
    
    I      = iBegin: iEnd;                                          % half year before, and half year after index
    index  = I >= (i - 1)*nptperyear + 1 & I <= i*nptperyear; % The current year index
    % I    = (i - 1)*pntsPerYear + 1:i*pntsPerYear;
    if IsUpdatingW
        yPred = HANTS2(y(I), I', w(I), nf, ylu, nptperyear, iters, modweight);
    else
        yPred = HANTS (y(I), I', 'Mid', nf, [], nptperyear, fet, noutmax, delta); %Lo 
    end
    yfit{i}  = yPred(index);
    % [y, amp,phi] = HANTS(pntsPerYear, nf, xi(I), I', 'Lo', low,high, fet, noutmax, delta);
    % yfit{i} = ReconHANTSData(amp, phi, pntsPerYear * 4);
end
yfit  = cell2mat(yfit);
% according to GOF index to select the most appropriate nf
[NASH_coef, R2_coef, RMSE, bias, pval, n] = NSE(y, yfit, false);
fprintf('HANTS : NSE = %.3f, R2 = %.3f, RMSE = %.3f, bias = %.3f\n', ...
    NASH_coef, R2_coef, RMSE, bias);
% end

% lgds = cellfun(@(i) ['iter:', num2str(i)], num2cell(1:5), 'UniformOutput', false);
% lgds = ['Original VI', lgds]; %#ok<AGROW>
% legend(lgds);

% [NASH_coef, R2_coef, RMSE, pval, n] = NSE(y, yfit2, IsPlot)

% [y, amp,phi] = HANTS(pntsPerYear, nf, xi(I), I', 'Lo', low,high, fet, noutmax, delta);
% y_new = ReconHANTSData(amp,phi,pntsPerYear);
% plot(xi(I)); hold on
% plot(y);
% plot(y_new);
% legend({'origin', 'hants', 'recon'})