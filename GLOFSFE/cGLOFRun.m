classdef cGLOFRun < cGLOFImageSet 
%CGLOFRUN
% contains a set of images for the processing. List of image index for 
% pairs is additionaly designated.
%
% Copyright (c) 2018 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php    
    
    properties
        
        % record
        RunConditions    % Run conditions(flow conditions), struct
        
        % data
        PairLists     % image pair index (np x 2)
        np            % number of image pairs
        
    end
    
    methods
        % constructor
        function obj=cGLOFRun(varargin)
            obj@cGLOFImageSet(varargin{:});
            obj=setPairList(obj);
        end
        
        function obj=setPairList(obj,PairLists)
            narginchk(1,2);        % pair list
            if nargin==1
                nk=obj.Dim(3);
                obj.PairLists=[1:nk-1;2:nk]'; % time sequential images
            else
                if size(PairLists,1)>=2&&size(PairLists,2)==2
                    obj.PairLists=PairLists;
                else
                    error('not proper PairLists size');
                end
            end
            obj.np=size(obj.PairLists,1);
        end
        
    end
    methods (Static)

    end
    
end

