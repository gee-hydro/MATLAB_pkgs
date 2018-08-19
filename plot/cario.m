% SAVE figure to file
% 
% @param file       String, file name to be saved
% @param papersize  Numeric Vector [width, height]
% @param type       seealso MATLAB print type
% @param resolution e.g. '-r300', seealso MATLAB print type
% @param show       If true, file will be opened.
function cario(file, papersize, type, resolution, show)

if nargin < 5, show       =    true; end
if nargin < 4, resolution = '-r300'; end
if nargin < 3, type       = '-dpdf'; end
if nargin < 2, papersize  =  [8, 6]; end
if nargin < 1, file       =  ['Figure.', type(3:end)]; end

set(gcf, 'PaperUnits', 'inches', 'PaperPosition',[0, 0, papersize], ...
    'PaperType', '<custom>', 'PaperSize', papersize)
print(gcf, file, type, resolution)  

if show, system(file); end
