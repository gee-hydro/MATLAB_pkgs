
function color_bar(maxI)
    
maxI = maxI + 1;
% caxis([-1, maxI]);
colormap([1, 1, 1; jet(maxI)]); bar = colorbar;
% set(bar, 'limit', [0, maxI])