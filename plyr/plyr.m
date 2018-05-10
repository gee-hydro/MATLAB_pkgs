classdef plyr
    methods (Static)
        function out = llply(list, func)
            out = cellfun(func, list, 'UniformOutput', false);
        end
        
        function out = laply(list, func)
            out = cellfun(func, list, 'UniformOutput', true);
        end

        %% Melt list to table
        %INPUTS:
        % list : The cell variable you want to melt
        % names: names for every list
        % variable_name: The new add column name, default is name
        function df = melt_list(list, names, variable_name)
            if nargin < 2, names = 1:length(list); end
            for i = 1:length(list)
                xt = list{i};
                if ~isempty(xt)
                    nrow = size(xt, 1);
                    % xt.ID = ones(nrow, 1) * i;
                    xt.name = repmat(names(i), nrow, 1);
                    list{i} = xt;
                end
            end
            df = cat(1, list{:});
            df.name = categorical(df.name); % as.factor
            if nargin == 3
               df.Properties.VariableNames{end} = variable_name;
            end
        end
        
        % List consist of structures, and assume that every struct have the same
        % table
        function result = melt_list_st(list)
            s     = list{1};
            names = fieldnames(s);
            % add new column ID in table
            for i = 1:length(list)
                s = list{i};
                for j = 1:length(names)
                    eval(sprintf('xt = s.%s;', names{j}))
                    if ~isempty(xt)
                        xt.ID = ones(size(xt, 1), 1) * i;
                        eval(sprintf('s.%s = xt;', names{j}));
                    end
                end
                list{i} = s;
            end
           %% transpose
            nvar   = length(names);
            result = [];
            for j = 1:nvar
                eval(sprintf('f = @(s) s.%s;', names{j}))
                x = cellfun(f, list, 'UniformOutput', false);
                % remove empty cells
                I_rem = ~cellfun(@isempty, x);
                x = cat(1, x{I_rem});
                eval(sprintf('result.%s = x;', names{j}));
                % If save, then write file to csv
                writetable(x, sprintf('%s.csv', names{j}))
            end
        end
        
        function list = split_list(df, names)
        n    = length(names);
        list = cell(n, 1);
        for i = 1:n
            list{i} = df(contains(df.site, names{i}), :);
        end
        end
        % remove empty list in the input
        function out = rm_empty(list)
            I_rem = ~laply(list, @isempty);
            out   = list(I_rem);
        end
    end
end