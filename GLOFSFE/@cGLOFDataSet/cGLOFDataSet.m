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
%         CalImagesOrg     % Original Calibration images
        Mask             % Mask image
        ROI              % Region of Interest

        n_med            % median filter settings for Calibration images
        mfld             % filtering cal image names, cell of strings
        
        ImgList          % GLOF image file list
        PairList         % GLOF image pair file index
        FileList         % GLOF image file index 
        
        datasize         % data size (ni,nj,nk,np)
        OrgDim           % original image size (ni,nj)
        ResDim           % rescaled image size (ni,nj)
        max_image
        
        % image and grid buffers
        bufferSize
        bufferIndex
        ImgBuffer
        CalImgBuffer
        BufferList
        QueryGrid    
        
        %%% Calibration parameters include followings, struct
        % alpha          image intensity per oil-thickness [1/meter]
        % beta           length scale [pixel/meter]
        % gamma          frame rate [frame/second]
        % visc_oil       viscosity of oil [Pa*s]
        % scale          image rescaling factor (0.5->50%)
        % angle          image rotating angle [deg]
        % CrdVtr        Coordinate vector on image. 2-by-n
        % CrdVtr_p      Coordinate vector on projected image
        % Texp          camera exposure time of run, alpha, background, and dark images 
        CalPara          =struct('alpha',1,'beta',1,'gamma',1,'visc_oil',1,...
                                 'scale',1,'angle',0,'CrdVtr',[],'CrdVtr_p',[],...
                                 'Texp',struct('run',1,'alpha',1,'bg',1,'dark',1));

        flagRescale      =false;     
        flagRescaleReady =false;     
        flagRescaleReadyGpu =false;  
        flagRescaled     =false;     
        
        flagCalPara      =false;     
        flagImgCalibrated=false;     
        
        flagImgLoaded    =false;     
        flagDataChecked  =false;     
        flagSetBuffer    =false;     
        flagSetGpuBuffer =false;     
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
            
            % initial operation
            setRunImages(obj);
        end

        %%
        function s = saveobj(obj)
            s.Name=obj.Name;
            s.oCase=obj.oCase;
            s.oRuns=obj.oRuns;

            s.CalPara=obj.CalPara;
            s.n_med=obj.n_med;            
            s.mfld=obj.mfld;
            s.datasize=obj.datasize;
            
            s.CalImages=obj.CalImages;
%             s.CalImagesOrg=obj.CalImagesOrg;
            s.Mask=obj.Mask;
            s.ROI=obj.ROI;
        
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
                obj.datasize=s.datasize;
                
                obj.CalImages=s.CalImages;
%                 obj.CalImagesOrg=s.CalImagesOrg;
                obj.Mask=s.Mask; 
                obj.ROI=s.ROI; 
                
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
