function [ In ] = LoadImages(input_path,fmt,nk,p)
narginchk(1,4);

if nargin==1 || exist(input_path,'file')==2
    % input a file
    [input_path,File_Names,fmt] = fileparts(input_path);
    File_Names={strcat(File_Names,fmt)};
    fmt=fmt(2:end);
    nk=1;
    p=1;
else
    % find files have specific format
    File_DATA  = dir(fullfile(input_path,['*.',fmt]));
    File_Names = {File_DATA.name};
    if nargin<3
        nk=size(File_Names,2);
    end
    if nargin<4
        p=1:nk;
    end
end

if isequal(fmt,'b16')
    I1=readB16.readB16(fullfile(input_path,File_Names{1}));
    if nk==1
        In=I1;
    else
        nz=size(I1);
        ni=nz(1);
        nj=nz(2);
        if length(nz)==2
            In=zeros(ni,nj,nk,'double');
            In(:,:,1)=I1;
            for i=2:nk
                I1=readB16.readB16(fullfile(input_path,File_Names{p(i)}));
                In(:,:,i)=I1;
            end
        else
            ncdim=nz(3);
            In=zeros(ni,nj,ncdim,nk,'double');
            In(:,:,:,1)=I1;
            for i=2:nk
                I1=readB16.readB16(fullfile(input_path,File_Names{p(i)}));
                In(:,:,:,i)=I1;
            end
            
        end
    end
elseif isequal(fmt,'mat')
    I_file=matfile(fullfile(input_path,File_Names{1}));
    I1=I_file.In;
    if nk==1
        In=double(I1);
    else
        nz=size(I1);
        ni=nz(1);
        nj=nz(2);
        if length(nz)==2
            In=zeros(ni,nj,nk,'double');
            In(:,:,1)=I1;
            for i=2:nk
                I_file=matfile(fullfile(input_path,File_Names{p(i)}));
                I1=I_file.In;
                In(:,:,i)=I1;
            end
        else
            ncdim=nz(3);
            In=zeros(ni,nj,ncdim,nk,'double');
            In(:,:,:,1)=I1;
            for i=2:nk
                I_file=matfile(fullfile(input_path,File_Names{p(i)}));
                I1=I_file.In;
                In(:,:,:,i)=I1;
            end
        end
    end
else
    I1=imread(fullfile(input_path,File_Names{1}));
    if nk==1
        In=double(I1);
    else
        nz=size(I1);
        ni=nz(1);
        nj=nz(2);
        if length(nz)==2
            In=zeros(ni,nj,nk,'double');
            In(:,:,1)=I1;
            for i=2:nk
                I1=imread(fullfile(input_path,File_Names{p(i)}));
                In(:,:,i)=I1;
            end
        else
            ncdim=nz(3);
            In=zeros(ni,nj,ncdim,nk,'double');
            In(:,:,:,1)=I1;
            for i=2:nk
                I1=imread(fullfile(input_path,File_Names{p(i)}));
                In(:,:,:,i)=I1;
            end
            
        end
    end
end

end

