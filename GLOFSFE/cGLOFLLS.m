classdef cGLOFLLS
%CGLOFLLS
% Contains dataset and obtained tau field, a representative GLOF image.
%
% Copyright (c) 2018 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php
    
    properties
        
        oDataSet
        
        tau_x
        tau_y
        
        img
      
    end
    
    methods
        
        function obj=cGLOFLLS()
            
        end
        
        function obj=runLLS(obj,oDataSet,option)
            narginchk(2,3);
            if nargin==2
                option='cpu';
            end
            
            % images and LLS matrix loading
            [ tau_x, tau_y ] = fLLS(oDataSet,option); %#ok<*PROPLC>
                        
            obj.tau_x=tau_x;
            obj.tau_y=tau_y;
            
            % save last image
            obj.img=oDataSet.ImgBuffer(:,:,oDataSet.bufferIndex);
            
            % clear image buffer
            oDataSet.clearTemps;
            % keep process conditions
            obj.oDataSet=oDataSet;
        end
        
        function [realtau_x,realtau_y,img]=getRealTau(obj)
            CalPara=obj.oDataSet.CalPara;
            alpha=CalPara.alpha;
            beta=CalPara.beta;
            gamma=CalPara.gamma;
            visc_oil=CalPara.visc_oil;
            realtau_x=obj.tau_x*visc_oil*alpha*gamma/beta;
            realtau_y=obj.tau_y*visc_oil*alpha*gamma/beta;
            img=obj.img;
        end
        
        function [tau_x,tau_y,img]=getTau(obj)
            tau_x=obj.tau_x;
            tau_y=obj.tau_y;
            img=obj.img;
        end
        
        function s = saveobj(obj)
            s.oDataSet=obj.oDataSet;
            
            s.tau_x=obj.tau_x;
            s.tau_y=obj.tau_y;
            
            s.img=obj.img;           
        end
        function save(obj,fname,varargin)
            s=obj.saveobj; %#ok<*NASGU>
            save(fname,'-struct','s',varargin{:});
        end
    end
    
    methods (Static)
        function obj = loadobj(s)
            if isstruct(s)
                obj=cGLOFLLS();
                
                obj.oDataSet=s.oDataSet;
                obj.tau_x=s.tau_x;
                obj.tau_y=s.tau_y;
                obj.img=s.img;
            else
                obj=s;
            end
        end
        function obj = load(fname)
            temp=load(fname);
            obj=cGLOFLLS.loadobj(temp);
        end
    end
    
end

