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
        PairList     % image pair index (np x 2)
        np            % number of image pairs
        
    end
    
    methods
        % constructor
        function obj=cGLOFRun(varargin)
            obj@cGLOFImageSet(varargin{:});
            obj=setPairList(obj);
        end
        
        function obj=setPairList(obj,PairList)
            narginchk(1,2);        % pair list
            if nargin==1
                nk=obj.Dim(3);
                obj.PairList=[1:nk-1;2:nk]'; % time sequential images
            else
                if size(PairList,1)>=2&&size(PairList,2)==2
                    obj.PairList=PairList;
                else
                    error('not proper PairList size');
                end
            end
            obj.np=size(obj.PairList,1);
        end
        
    end
    methods (Static)

    end
    
end

