%DIRNAME
%   Get the dirname of the input path

function vargout = dirname(paths)

if iscell(paths)
    vargout = cellfun(@dirnameI, paths, 'UniformOutput', false);
elseif ischar(paths)
    vargout = dirnameI(paths);
else
    error('The type of input path should be char or cell char!');
end

function pathstr = dirnameI(path)
[pathstr,name,ext] = fileparts(path); %#ok<ASGLU>
