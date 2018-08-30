classdef cGLOFDataSet < matlab.mixin.Copyable
%CGLOFDATASET
% contains case and runs, calibration images.
% manages calibration parameters, calibration process, and calibrated 
% images.
%
% Copyright (c) 2018 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php    

    properties
        
        % record
        Name             %
        
        % data
        oCase            % case obj
        oRuns            % run objs, cell
        
        CalImages        % Calibration images
        Mask             % Mask image
        CalImagesOrg     % Original Calibration images
        
        n_med            % median filter settings for Calibration images
        mfld
        
        ImgList          % GLOF image file list
        PairList         % GLOF image pair file index
        FileList         % GLOF image file index 
        
        datasize         % data size (ni,nj,nk,np)
        max_image
        
        bufferSize
        bufferIndex
        ImgBuffer
        BufferList
        
        % calibration parameters
        CalPara          % calibration parameters include followings, struct
        % alpha          % image intensity per oil-thickness [1/meter]
        % beta           % length scale [pixel/meter]
        % gamma          % frame rate [frame/second]
        % visc_oil       % viscosity of oil [Pa*s]
        % scale          % image rescaling factor (0.5->50%)
        % angle          % image rotating angle [deg]
        
        flagImgLoaded
        flagRescaled     %
        flagRescale
        flagImgCalibrated%
        flagCalPara      %
        flagSetBuffer    %
    end
    
    methods
        % constructor
        function obj=cGLOFDataSet(o_case,o_runs,name)
            narginchk(2,3);
            if nargin==2
                obj.Name='DefaultDataSetName';
            else
                obj.Name=name;
            end
            
            obj.oCase=o_case;
            if iscell(o_runs)
                obj.oRuns=o_runs;
            elseif isa(o_runs,'cGLOFRun')
                obj.oRuns{1}=o_runs;
            else
                error('inappropriate cGLOFRun');
            end
            
            % initial values
            obj.CalPara=struct('scale',1,'angle',0,...
                'alpha',1,'beta',1,'gamma',1,'visc_oil',1);
            obj.flagImgLoaded=false;
            obj.flagRescaled=false;
            obj.flagRescale=false;
            obj.flagImgCalibrated=false;
            obj.flagCalPara=false;
            obj.flagSetBuffer=false;
            setRunImages(obj);
        end
    
        function setRunImages(obj)            
            CollectPairList(obj);
            ni=obj.oRuns{1}.Dim(1);
            nj=obj.oRuns{1}.Dim(2);
            nk=size(obj.FileList,1);
            np=size(obj.PairList,1);
            
            obj.datasize=[ni,nj,nk,np];
            obj.max_image=obj.oRuns{1}.max_image;
        end
        
        function LoadData(obj)
            fprintf(1,'(%s) %s',obj.Name,'load dataset images...');
            LoadCalImages(obj);
            LoadMaskImages(obj);
            setRunImages(obj);
            obj.flagImgLoaded=true;
            if obj.flagRescale==true
                runRescaleRotImages(obj);
            end
            if obj.flagCalPara==true
                setCalPara(obj);
            end
            fprintf(1,'%s\n','done');
        end
        
        %%
        % rescaling and rotating images
        function setRescaleRot(obj,varargin)
            if max(size(varargin))==1
                scale=varargin{1};
                angle=0;
            elseif max(size(varargin))>=2
                scale=varargin{1};
                angle=varargin{2};
            end
            obj.CalPara.scale=scale;
            obj.CalPara.angle=angle;
            
            obj.flagRescale=true;            
        end
        
        % median filtering selected cal image(s)
        function setMedianCalImages(obj,n_med,fld)
            obj.n_med=n_med;
            obj.mfld=cell(fld);
        end
        
        %% image buffer
        function [I1,I2]=getPair(obj,np)       
            I1=getImage(obj,obj.PairList(np,1),obj.PairList(np,2));
            I2=getImage(obj,obj.PairList(np,1),obj.PairList(np,3));    
        end

        %%
        function s = saveobj(obj)
            
            s.Name=obj.Name;
            s.oCase=obj.oCase;
            s.oRuns=obj.oRuns;

            s.CalPara=obj.CalPara;
            s.n_med=obj.n_med;            
            s.mfld=obj.mfld;
        
            s.flagRescale=obj.flagRescale;
            s.flagCalPara=obj.flagCalPara;
            
        end
        function save(obj,fname,varargin)
            s=obj.saveobj; %#ok<*NASGU>
            save(fname,'-struct','s',varargin{:});
        end
        
    end
    
    methods (Static)
        function obj = loadobj(s)
            if isstruct(s)
                obj=cGLOFDataSet(s.oCase,s.oRuns,s.Name);
                
                obj.CalPara=s.CalPara;
                obj.n_med=s.n_med; 
                obj.mfld=s.mfld;
                obj.flagRescale=s.flagRescale;
                obj.flagCalPara=s.flagCalPara;

            else
                obj=s;
            end
        end
        function obj = load(fname)
            temp=load(fname);
            obj=cGLOFDataSet.loadobj(temp);
        end
    end
   
    
    
end
