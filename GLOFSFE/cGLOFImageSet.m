classdef cGLOFImageSet < handle
%CGLOFIMAGESET
% contains a set of images. File directories, image parameters, and 
% normalization process were included.
%
% Copyright (c) 2018 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php     

    properties
        
        % record
        Name           % image set name, string
        ImgConditions  % Image conditions(i.e. camera), struct
        
        Dir            % containing file directory
        FileList       % list of image directories
        
        Dim            % image dimension [ni nj nk]
        
        fmt            % image format
        max_image      % maximum image intensity[count] for normalization
        
        In             % image matrix [ni nj nk]
        
        flagMatfile=false;
        flagMatLoaded=false;
    end
    
    methods
        
        %% constructor
        function obj=cGLOFImageSet(Idir,fmt,max_image)
            % initial parameters
            narginchk(2,3);
            obj.Name='ImageSet_name';
            flagReadbit=true;
                
            obj.Dir=Idir;
            obj.fmt=fmt;
            if nargin==3
                obj.max_image=max_image;
                flagReadbit=false;
            end
                

            if exist(Idir,'file')==2 && strcmp(fmt,'mat')
                % directly load a mat file
                obj.flagMatfile=true;
                I_file=matfile(Idir);
                obj.Dim=size(I_file.In);
                obj.max_image=1;
            else
                % load first image, set Dim
                if exist(obj.Dir,'dir')
                    File_DATA  = dir(fullfile(obj.Dir,['*.',fmt]));  %read images dir_data
                    File_Names = {File_DATA.name};
                    if size(File_Names,1)==0
                        error('file was not found\n%s',fullfile(obj.Dir,['*.',fmt]));
                    end
                    imgfile=fullfile(obj.Dir,File_Names{1});
                    nk=size(File_Names,2);
                else
                    imgfile=obj.Dir;
                    nk=1;
                end
                
                Im1=LoadImages(imgfile); 
                [ni,nj]=size(Im1); % if I1 is 3d -> error
     
                obj.Dim=[ni nj nk];
                
                % make file list
                if nk==1
                    obj.FileList{1,1}=imgfile;
                else
                    for k=1:nk
                        obj.FileList{k,1}=[obj.Dir,File_Names{k}];
                    end
                end
                
            end
            
            
            % decide max_image
            if flagReadbit
                if isa(Im1,'uint8')
                    obj.max_image=2^8-1;
                elseif isa(Im1,'uint16')
                    obj.max_image=2^16-1;
                elseif isa(Im1,'logical')
                    obj.max_image=1;
                else
                    obj.max_image=1;
                end
            end
            
        end
        
        %% images given in matrix
        function importMat(obj,In)
            obj.In=In;
            obj.flagMatLoaded=true;
            obj.Dim=size(In);
        end
        function loadMat(obj)
            if ~obj.flagMatLoaded
                I_file=matfile(obj.Dir);
                obj.In=I_file.In;
                obj.flagMatLoaded=true;
            end
        end
        function clearMat(obj)
            obj.In=[];
            obj.flagMatLoaded=false;
        end
        %% load image from file(s)
        % get a image
        function I=getI(obj,k)
            if obj.flagMatfile
                loadMat(obj);
                I=double(obj.In(:,:,k));
            else
                I=double(LoadImages(obj.FileList{k}))./obj.max_image;
            end
        end
        % get images
        function In=getIn(obj)
            if obj.flagMatfile
                loadMat(obj);
                In=double(obj.In);
            else
                In=double(LoadImages(obj.Dir,obj.fmt))/obj.max_image;
            end
        end
        % get an averaged image
        function Iave=getIave(obj)
            if obj.flagMatfile
                loadMat(obj);
                Iave=double(mean(obj.In,3));
            else
                Iave=mean(double(LoadImages(obj.Dir,obj.fmt)),3)/obj.max_image;
            end
        end
        
        
    end
    
end

