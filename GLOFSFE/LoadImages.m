function [ In ] = LoadImages(input_path,fmt,nk,p)
narginchk(1,4);

if nargin==1
    % input a file
    [input_path,File_Names,fmt] = fileparts(input_path);
    File_Names={strcat(File_Names,fmt)};
    tt= split(fmt,'.');
    fmt=tt{end};
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
    Im1=readB16.readB16(fullfile(input_path,File_Names{1}));
    [ni,nj]=size(Im1);
    
    In=zeros(ni,nj,nk,'double');
    for i=1:nk
        I1=readB16.readB16(fullfile(input_path,File_Names{p(i)}));
        In(:,:,i)=I1;
    end
    
else
    Im1=imread(fullfile(input_path,File_Names{1}));
    [ni,nj]=size(Im1);
    
    In=zeros(ni,nj,nk,'double');
    for i=1:nk
        I1=imread(fullfile(input_path,File_Names{p(i)}));
        In(:,:,i)=I1;
    end
end

end

