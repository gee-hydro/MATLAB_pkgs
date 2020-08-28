function [yr, amp, phi] = HANTS2(y, ts, w, nf, ylu, nptperyear, iters, modweight)
% Update: 2017-10-27, Dongdong Kong
% [yr, amp,phi] = HANTS(nptperyear,nf,y,ts,HiLo,low,high,fet,dod,delta)
% HANTS processing
%
% Wout Verhoef, NLR, Remote Sensing Dept. June 1998
%
% Converted to MATLAB:
% Mohammad Abouali (2011)
%
% NOTE: This version is tested in MATLAB V2010b. In some older version you
% might get an error on line 117. Refer to the solution provided on that
% line.
%
% Modified:
%   Apply suppression of high amplitudes for near-singular case by
%   adding a number delta to the diagonal elements of matrix A,
%   except element (1,1), because the average should not be affected
%
%   Output of reconstructed time series in array yr June 2005
%
%   Change call and input arguments to accommodate a base period length (nptperyear)
%   All frequencies from 1 (base period) until nf are included
% 
% Parameters
%
% Inputs:
%   ni    = nr. of images (total number of actual samples of the time
%           series)
%   nptperyear    = length of the base period, measured in virtual samples
%           (days, dekads, months, etc.). nptperyear in timesat.
%   nf    = number of frequencies to be considered above the zero frequency
%   y     = array of input sample values (e.g. NDVI values)
%   ts    = array of size ni of time sample indicators
%           (indicates virtual sample number relative to the base period);
%           numbers in array ts maybe greater than nptperyear
%           If no aux file is used (no time samples), we assume ts(i)= i,
%           where i=1, ..., ni
%   ylu   = [low, high] of time-series y (values outside the valid range are rejeced
%           right away)
%
% Outputs:
%
% amp   = returned array of amplitudes, first element is the average of
%         the curve
% phi   = returned array of phases, first element is zero
% yr    = array holding reconstructed time series

if nargin < 7, iters = 2; end
if nargin < 8 || ~isa(modweight, 'function_handle'), modweight = ModWeights.default; end

% coder.varsize('y', 'ts', [100, 1], [1, 0])
ni  = length(y); % total number of actual samples of the time series

mat = zeros(min(2*nf+1,ni),ni,'single');
amp = zeros(nf+1,1, 'single');
phi = zeros(nf+1,1, 'single');
yr  = zeros(ni,1  , 'single');
zr  = zeros(ni*2+1, 'single');

% ra = zeros(nf, 1, 'single');
% rb = zeros(nf, 1, 'single');
% if (Opt.FirstRun==true)

nr      = min(2*nf+1, ni);
% noutmax = ni - nr - dod;
dg      = 180.0/pi;

ang = 2.*pi*(0:nptperyear-1)/nptperyear;
cs  = cos(ang);
sn  = sin(ang);
%     Opt.FirstRun=false;
% end

mat(1,:)=1.0;
% f*2*pi*[0:nptperyear-1]/nptperyear; mod replace it
for i = 1:nf
    I = 1 + mod(i * (ts - 1), nptperyear);
    mat(2*i  , :) = cs(I);
    mat(2*i+1, :) = sn(I);
end
% i=1:nf;
% for j=1:ni
%     index = 1 + mod(i*(ts(j)-1), nptperyear);
%     mat(2*i  ,j) = cs(index);
%     mat(2*i+1,j) = sn(index);
% end

% w: weights of every points
% w = ones(ni,1);

for i = 1:iters
    w( y<ylu(1) | y>ylu(2)) = 0;
    za = mat*(w.*y);
    
    A = mat * diag(w) * mat'; %how to know A was amplitude
    % A = A + diag(ones(nr,1))*delta;
    % A(1,1) = A(1,1) - delta;
    zr = A\za;
    
    yr = mat'*zr;
    w = modweight(y, yr, w, 0.5, i, nptperyear); %wfact = 0.5;
end
% while ((~ready)&&(nloop < nloopmax))
%     nloop=nloop+1;
%     za = mat*(p.*y);
%     A = mat * diag(p) * mat'; %how to know A was amplitude
%     A = A + diag(ones(nr,1))*delta;
%     A(1,1) = A(1,1) - delta;
%     zr = A\za;
    
%     yr = mat'*zr;
%     if sHiLo == 0
%         diffVec = abs(yr - y); %20171026, add top and low outliers removing method
%     else
%         diffVec = sHiLo * (yr - y);
%     end
%     err = p.*diffVec;
    
%     [~, rankVec] = sort(err,'ascend');
%     % The above line may not be recognized on some older MATLAB versions.
%     % Simply comment the above line and uncomment the line below.
%     %    [tmp, rankVec]=sort(err,'ascend');
    
%     maxerr = diffVec(rankVec(ni));
%     ready  = (maxerr <= fet) || (nout==noutmax);
%     if (~ready)
%         i=ni;
%         j=rankVec(i);
%         while ( (p(j)*diffVec(j) > maxerr*0.5)&&(nout<noutmax) )
%             p(j) = 0;
%             nout = nout+1;
%             i = i-1;
%             j = rankVec(i); %fixerror, rank, 20171026
%         end
%     end
% end

if nargout > 1
    amp(1)   = zr(1);
    phi(1)   = 0.0;
    
    % zr(ni+1) = 0.0;
    i        = (2:2:nr)';
    ifr      = (i+2)/2;
    ra       = zr(i);
    rb       = zr(i+1);
    amp(ifr) = sqrt(ra.*ra+rb.*rb);
    phase    = atan2(rb, ra)*dg;
    phase(phase<0) = phase(phase<0) + 360;
    phi(ifr) = phase;
end
end