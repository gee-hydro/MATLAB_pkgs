function files = dirR(indir, pattern, fullName)
%DIR Summary of this function goes here
%   模仿R语言dir函数
%
% pattern:
%   Regular expression, specified as a character vector, a cell array 
%   of character vectors, or a string array. Each expression can contain 
%   characters, metacharacters, operators, tokens, and flags that specify 
%   patterns to match in filename.

if nargin == 1, pattern  = '.*';  end
%   Check the Input indir variable
if nargin > 1
    if indir(end) ~= '\'
        indir = [indir, '\'];
    end
end
if nargin < 3, fullName = true; end

files = dir(indir); 
files = {files.name};
matched = regexp(files, pattern, 'match');
I = ~cellfun(@isempty, matched);

files = files(I);

%row cell into column cell
files = reshape(files, length(files), 1);
if fullName; files = strcat(indir, files); end
end




