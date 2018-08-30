classdef cGLOFCase < matlab.mixin.Copyable
%CGLOFCASE
% contains directories of calibration images.
% includes functions for calibration data acquisition.
%
% Copyright (c) 2018 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php    

    properties
        
        % record
        Name       % case name, string
        Conditions % case conditions(flow conditions), struct
        
        % data
        % calibration images
        % 1:dark 2:bg 3:exc 4:scale 5:alpha
        DirCal         % directories of calibration images folder, struct
        
        cal_fmt        % cal image format
        max_image      % maximum image intensity[count] for normalization
        
        FileMask        % mask images file directory/or mask matrix itself
        
        scale_points
        scale_length
        flagScale
        
        oil_drops
        v_drop
        flagDrops
    end
    
    
    methods
        
        % constructor
        function obj=cGLOFCase(casename)
            % initial values
            obj.DirCal=struct('dark',[],'bg',[],'exc',[],'scale',[],'alpha',[]);
            obj.FileMask=[];
            obj.Name='case_name';
            obj.flagScale=false;
            obj.flagDrops=false;
            
            if nargin==1&&ischar(casename)
                obj.Name=casename;
            elseif nargin==1
                error('Case name must be char');
            end
            
        end
        
        % setting directories of calibration image sets
        function setDirCal(obj,dir_cal,fmt,max_image)
            if isstruct(dir_cal)
                obj.DirCal=dir_cal;
            elseif iscell(dir_cal)
                obj.DirCal.dark=dir_cal{1};
                obj.DirCal.bg=dir_cal{2};
                obj.DirCal.exc=dir_cal{3};
                obj.DirCal.scale=dir_cal{4};
                obj.DirCal.alpha=dir_cal{5};
            else
                error('wrong DirCal format');
            end
            obj.cal_fmt=fmt;
            obj.max_image=max_image;
        end
        
        function setFileMask(obj,file_mask)
            obj.FileMask=file_mask;
        end
        
        function [scale_points,scale_length]=getScale(obj)
            if obj.flagScale==false
                obj.setScale(obj);
            end
            scale_points=obj.scale_points;
            scale_length=obj.scale_length;
        end
        
        function [oil_drops,v_drop]=getOilDrops(obj)
            if obj.flagScale==false
                obj.setOilDrops(obj);
            end
            oil_drops=obj.oil_drops;
            v_drop=obj.v_drop;
        end
        
        function s = saveobj(obj)
            s.Name = obj.Name;
            s.Conditions = obj.Conditions;
            
            s.DirCal=obj.DirCal;
            s.cal_fmt=obj.cal_fmt;
            s.max_image=obj.max_image;
            s.FileMask=obj.FileMask;
            
            s.scale_points=obj.scale_points;
            s.scale_length=obj.scale_length;
            s.flagScale=obj.flagScale;
            s.oil_drops=obj.oil_drops;
            s.v_drop=obj.v_drop;
            s.flagDrops=obj.flagDrops;
        end
        function save(obj,fname,varargin)
            s=obj.saveobj; %#ok<*NASGU>
            save(fname,'-struct','s',varargin{:});
        end
        
    end
    
    methods (Static)
        function obj = loadobj(s)
            if isstruct(s)
                obj=cGLOFCase(s.Name);
                obj.Name=s.Name;
                obj.Conditions=s.Conditions;             
                
                obj.DirCal=s.DirCal;
                obj.cal_fmt=s.cal_fmt;
                obj.max_image=s.max_image;
                obj.FileMask=s.FileMask;
                
                obj.scale_points=s.scale_points;
                obj.scale_length=s.scale_length;
                obj.flagScale=s.flagScale;
                obj.oil_drops=s.oil_drops;
                obj.v_drop=s.v_drop;
                obj.flagDrops=s.flagDrops;
                
            else
                obj=s;
            end
        end
        function obj = load(fname)
            temp=load(fname);
            obj=cGLOFCase.loadobj(temp);
        end
    end    
    
end

