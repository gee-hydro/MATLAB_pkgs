function files = dirR(indir, pattern, fullName)
%DIR Summary of this function goes here
%   模仿R语言dir函数
if nargin == 1, pattern  = '';  end
%   Check the Input indir variable
if nargin > 1
    if indir(end) ~= '\'
        indir = [indir, '\'];
    end
end
if nargin < 3, fullName = true; end

files = dir([indir, pattern]);
files = {files.name};

%row cell into column cell
files = reshape(files, length(files), 1);
if fullName; files = strcat(indir, files); end
end

