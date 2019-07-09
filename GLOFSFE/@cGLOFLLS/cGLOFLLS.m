classdef cGLOFLLS < handle
%CGLOFLLS
% Contains dataset and obtained tau field, a representative GLOF image.
%
% Copyright (c) 2018-2019 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php
    
    properties
        
        oDataSet
        
        tau
        tau_x
        tau_y
        
        PairMask=[];
        roi=struct('img',[],'node',[],'cell',[],'tau_x',[],'tau_y',[]);
        
        tau_local
        Uave
        Urms
        
        sens_stat =struct('sens',[],'ave',[],'var',[],'skew',[],'nSample',[],'sigma',[]);
        % sens_stat: image noise sensitivity in statistical method
        sens_analy=[];
        % sens_analy: image noise sensitivity in analytical method
        
        C
        d
        
        bAve
        Rsq
        
        img=struct('ins',[],'ave',[],'max',[],'min',[],'rms',[]);
        % img.ins: instantaneous image
        % img.ave: averanged-
        % img.max, img.min : maximum-, minimum-
        % img.rms: root mean squares of image
        
        flagLLS=false;
        flagUnc=false;
      
    end
    
    methods
        
        function obj=cGLOFLLS()
        end
        
        function runLLS(obj,oDataSet,varargin)
            narginchk(2,4);
            option=[];
            PairMask_in=[];
            
            if nargin>2
                for n=1:nargin-2
                    in=varargin{n};
                    if isnumeric(in)
                        PairMask_in=in;
                    elseif ischar(in)
                        option=in;
                    end
                end
            end
            if ~isempty(obj.PairMask)
               PairMask_in=obj.PairMask;
            end
            if isempty(option)
                option='cpu';
            end
            if isempty(PairMask_in)
                PairMask_in=ones(oDataSet.datasize(4),1);
            end
            
            obj.oDataSet=oDataSet;
            obj.PairMask=PairMask_in;
            
            use_gpu = ComputingOpt(option);
            
            % calculate LLS
            LLS(obj,use_gpu); 
            
            % clear image buffer
            obj.oDataSet.clearTemps;
            
            tauVec2Field(obj); 
            
            obj.flagLLS=true;
        end
        
        function runAnalysis(obj,varargin)
            if obj.flagLLS==false
                error('LLS is not processed');
            end
            narginchk(1,2);
            
            % images and LLS matrix loading
            Analysis(obj,varargin{:}); 
            % clear image buffer
            obj.oDataSet.clearTemps;
            
        end
        
        function runSensAnaly(obj,varargin)
            % image noise sensitivity
            % in analytical method
            
            if obj.flagLLS==false
                error('LLS is not processed');
            end
            if isempty(obj.oDataSet.ROI)
                fprintf(1,'Region of Interest is not set. Skip the analysis.\n');
                return
            end
            narginchk(1,2);
            use_gpu = ComputingOpt(varargin{:});
            
            % sensitivity field
            roi_img=obj.oDataSet.getROI();
            nW=size(roi_img,3);
            obj.sens_analy=cell(nW,1);% square of the sensitivity           
            
            for n=1:nW
                % check maximum memory usage
                % if memory is not enough, skip the analysis
                ArrayN=sum(sum(roi_img(:,:,n)));
                usingSize=(2*ArrayN)^2;
                userview = memory;
                maxSize=userview.MaxPossibleArrayBytes;
                if usingSize*34<maxSize
                    try
                        obj.sens_analy{n} = obj.SensAnaly(n, use_gpu); 

                    catch ME
                        fprintf(1,['\n===SensAnaly ERROR===\n',...
                                     'using memory: %.3e\n',...
                                     'message: %s\n',...
                                     '=====================\n'],usingSize,ME.identifier);
                    end
                else
                    fprintf(1,'ROI %d: matrix is too large.\n',n);
                end
            end
            
            obj.flagUnc=true;
            % clear image buffer
            obj.oDataSet.clearTemps;
        end
        
        function runSensStat(obj,sigma,nSample,varargin)
            % image noise sensitivity
            % in statistical(Monte Carlo) method
            % sigma: noise size
            % nSample: sampling number
            
            narginchk(3,4);
            use_gpu = ComputingOpt(varargin{:});
            
            obj.sens_stat.nSample=nSample;
            obj.sens_stat.sigma=sigma;
            try
                obj.SensStat(use_gpu);
            catch ME
                fprintf(1,['\n===SensStat ERROR===\n',...
                             'message: %s\n',...
                             '====================\n'],ME.identifier);
            end
            % clear image buffer
            obj.oDataSet.clearTemps;
        end

        function [realtau_x,realtau_y,img]=getRealTau(obj)
            if obj.oDataSet.flagCalPara
                [~,~,~,Unit_tau]=obj.oDataSet.getUnit();
            
                realtau_x=obj.tau_x*Unit_tau;
                realtau_y=obj.tau_y*Unit_tau;
                img=obj.img.ins;
            else
                fprintf(1,'Not calibrated. Output non-dimensional tau\n');
            	realtau_x=obj.tau_x;
                realtau_y=obj.tau_y;
                img=obj.img.ins;
            end
        end
        function [tau_x,tau_y,img]=getTau(obj)
            tau_x=obj.tau_x;
            tau_y=obj.tau_y;
            img=obj.img.ins;
        end
        function s = saveobj(obj)
            obj.oDataSet.clearTemps;
            obj.oDataSet.clearRunsMat;
            f = properties(obj)';
            for n=1:size(f(:),1)
                s.(f{n})=obj.(f{n});
            end
        end
        function save(obj,fname,varargin)
            s=obj.saveobj; %#ok<*NASGU>
            save(fname,'-struct','s',varargin{:});
        end
        
        %% methods for data reduction
        % claclulate LLS
        LLS(obj,option); 
        % analyze LLS results and the given images
        Analysis(obj,option);
        % statistical sensitivity analysis
        SensStat(obj,option);
        % analytical sensitivity analysis
        sens_analy=SensAnaly(obj, n, option);
        % convert tau vector to field
        tauVec2Field(obj);
        
    end
    
    methods (Static)
        function obj = loadobj(s)
            if isstruct(s)
                obj=cGLOFLLS();
                f=fieldnames(s)';
                for n=1:size(f(:),1)
                    obj.(f{n})=s.(f{n});
                end
            else
                obj=s;
            end
        end
        
        function obj = load(fname)
            temp=load(fname);
            obj=cGLOFLLS.loadobj(temp);
        end
        
        %% static functions
        
        % get scheme matrices
        [ Mave,Mc2f,SumFlux,Msigma,Diff_x,Diff_t ] = fScheme( ni,nj,Scell );
        % get effective dimension matrices
        [ resMeff,Meff,roi_node,roi_vec_x,roi_vec_y,roi_cell] = fEffMat( Mc2f,SumFlux,Msigma,Diff_x,roi );
        
        % get velocity field
        [ Ux,Uy ] = fOpticalFlow( h1, h2 );
        % rearrange tau vector field
        [ tau_x,tau_y ] = fTauVec2Field( tau,ni,nj );
        
        
    end
    
end

