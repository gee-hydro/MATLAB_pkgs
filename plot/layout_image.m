function layout_image(files, outfile, nrow, ncol, FUN, byrow)

if nargin < 3, nrow = 2; end
if nargin < 4, ncol = 2; end
if nargin < 6, byrow = false; end

f = cellfun(@imread, files, 'UniformOutput', false);


% if no FUN, it will skip
if nargin >= 5 && isa(FUN, 'function_handle'), f = FUN(f); end
if (length(f) < nrow*ncol), f{nrow*ncol} = []; end
temp = f{1}*0+255;

for i = 1:length(f)
    if isempty(f{i}), f{i} = temp; end
end

if byrow
    f = reshape(f, ncol, nrow)';
else
    f = reshape(f, nrow, ncol);
end

temp = arrayfun(@(irow) cat(2, f{irow, :}), 1:nrow, 'UniformOutput', false);
temp = cat(1, temp{:});

imwrite(temp, outfile)
