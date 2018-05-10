classdef makeVIDEO
    %MAKEVIDEO record current figures and make a video
    %   Author: Dongdong Kong, 21 Aug, 2017
    %USEAGE:
    %   video = makeVIDEO(IsSave, file);
    %   video.getframe();
    %   video.close();
    properties
        v;
        IsPlot;
    end
    
    methods
        function obj = makeVIDEO(IsPlot, file, frmrate)
            if nargin < 1, IsPlot = true;   end
            if nargin < 2, file = 'my.avi'; end
            if nargin < 3, frmrate = 2;     end
            
            % If no figures in current window, then create it.
            %             figs = findobj(0, 'type', 'figure');
            %             if isempty(figs)
            %                 figure('pos', [564, 279, 836, 557]);
            %             end
            obj.IsPlot      = IsPlot;
            if IsPlot
                obj.v           = VideoWriter(file); %, 'MPEG-4'
                obj.v.Quality          = 100;
%                 obj.v.CompressionRatio = 5;
                obj.v.FrameRate = frmrate;
                open(obj.v);
            end
        end
        
        function getframe(obj)
            if obj.IsPlot, writeVideo(obj.v, getframe(gcf)); end
        end
        
        function close(obj)
            if obj.IsPlot, close(obj.v); end
        end
    end
end