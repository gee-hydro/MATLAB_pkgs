function cmaplot(img, brks)
    
global colors region

range_clip = [25, 40, 73, 105];     % Tibetan Plateau
range_lat  = range_clip(1:2);
range_long = range_clip(3:4);

cellsize = 0.1;
long = range_long(1)+ cellsize/2 : cellsize:range_long(2);
lat  = range_lat(1) + cellsize/2 : cellsize:range_lat(2);

brks  = [0.1, 0.5, 1:6, 8, 10, 20, 40];
nbrks = length(brks);

% imagesc(long, lat, img')
[LONG, LAT] = meshgrid(long, lat);
contourf(LONG, LAT, img', 1:nbrks + 2, 'linestyle', 'none');

colormap(colors{:,:}/255);
caxis([1, nbrks + 2])
hold on;

plot(region.lon, region.lat, 'k-'); 

bar = colorbar;
set(bar, 'ytick', 2:nbrks+1, 'yticklabel', brks);
set(gca, 'Ydir','Normal')

set(gca, 'fontsize', 12, ... %'fontname', font, ...
                'xgrid', 'on', 'ygrid', 'on', ...
                'XMinorGrid', 'on','YMinorGrid', 'on', ...
                'ylim', [18, 55], 'xlim', [73, 135])