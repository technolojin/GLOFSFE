function LoadMaskImages(obj)
Dim=obj.oRuns{1}.Dim;
FileMask=obj.oCase.FileMask;

if isempty(FileMask)
    fprintf(1,'\n%s\n','mask is set to default');
    obj.Mask=true(Dim(1),Dim(2));
elseif ischar(FileMask)
    mask=double(imread(FileMask));
    obj.Mask=mask>0.5*max(mask(:));
elseif isnumeric(FileMask)||islogical(FileMask)
    obj.Mask=FileMask>0.5;
else
    error('invalid mask setting');
end

if sum(obj.Mask(:))==0
    error('no effective roi');
end
end
