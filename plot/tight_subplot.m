function ha = tight_subplot(Nh, Nw, gap, margin)
% tight_subplot creates "subplot" axes with adjustable gaps and margins
%
% margin = [top, right, bottom, left];
% ha = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
% gap    = [gap_h, gap_w]
% margin = [upper, left, lower, right]
%   in:  Nh      number of axes in hight (vertical direction)
%        Nw      number of axes in width (horizontaldirection)
%        gap     gaps between the axes in normalized units (0...1)
%                   or [gap_h gap_w] for different gaps in height and width
%        margin  margins in height and width in normalized units (0...1)
%                   [upper, left, lower, right]
%  out:  ha     array of handles of the axes objects
%                   starting from upper left corner, going row-wise as in
%                   going row-wise as in
%
%  Example: ha = tight_subplot(3,2,[.01 .03],[1, 1, 1, 1]*0.05)
%           for ii = 1:6; axes(ha(ii)); plot(randn(10,ii)); end
%           set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')

% Pekka Kumpulainen 20.6.2010   @tut.fi
% Tampere University of Technology / Automation Science and Engineering
%
% Modified By Dongdong Kong, 24 Aug'2017
% email: kongdd@live.cn

if nargin < 3, gap    = [.02, .02];      end
if nargin < 4, margin = ones(1, 4)*0.05; end

if numel(gap)==1, gap = [gap gap]; end
switch numel(margin)
    case 1
        margin = repmat(margin, 1, 4);
    case 2
        margin = repmat(margin, 1, 2);
    case 3
        margin = margin([1:end, end]);
    case 4
    otherwise
        error('plottable::Invalid margin!');
end

% marg_h = [lower, upper]
% marg_w = [left, right];
marg_h = margin([3, 1]);
marg_w = margin([4, 2]);

axh = (1-sum(marg_h)-(Nh-1)*gap(1))/Nh;
axw = (1-sum(marg_w)-(Nw-1)*gap(2))/Nw;

py = 1-marg_h(2)-axh;

ha = zeros(Nh*Nw,1);
ii = 0;
for ih = 1:Nh
    px = marg_w(1);
    
    for ix = 1:Nw
        ii = ii+1;
        ha(ii) = axes('Units','normalized', ...
            'Position',[px py axw axh], ...
            'XTickLabel', '', 'YTickLabel', '');
        px = px + axw + gap(2);
    end
    py = py - axh - gap(1);
end

