%BASENAME
%   Get the basename of the input path
function vargout = basename(paths)

if iscell(paths)
    vargout = cellfun(@basenameI, paths, 'UniformOutput', false);
elseif ischar(paths)
    vargout = basenameI(paths);
else
    error('The type of input path should be char or cell char!');
end

function name = basenameI(path)
[pathstr,name,ext] = fileparts(path); %#ok<ASGLU>
name = [name, ext];