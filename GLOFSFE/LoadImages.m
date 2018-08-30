function [ In ] = LoadImages(input_path,fmt,nk,p)
narginchk(2,4);

File_DATA  = dir(fullfile(input_path,['*.',fmt]));
File_Names = {File_DATA.name};

Im1=imread([input_path,File_Names{1}]);
[ni,nj]=size(Im1);

if nargin<3
    nk=size(File_Names,2);
end
if nargin<4
    p=1:nk;
end

In=zeros(ni,nj,nk,'double');

for i=1:nk
    I1=imread([input_path,File_Names{p(i)}]);
    In(:,:,i)=I1;
end


end

