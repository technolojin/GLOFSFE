function runRescaleRotCalMask(obj)
% cal images
fld=fieldnames(obj.CalImages);
nk=size(fld,1);
for k=1:nk
    img=obj.runRescaleRot(obj.CalImagesOrg.(fld{k}),0);
    %img(isnan(img))=0;
    obj.CalImages.(fld{k})=img;
end

% Mask
mask=double(obj.Mask);
img=obj.runRescaleRot(mask,0);
obj.Mask=img>0.5;

% ROIs
if ~isempty(obj.ROI)
    roiDim=size(obj.ROI);
    if isequal(roiDim([1,2]),obj.oRuns{1}.Dim([1,2]))
        roi=double(obj.ROI);
        ROI=obj.runRescaleRot(roi,0);
        obj.ROI=ROI;
    end
end

% update datasize
ni=size(img,1);
nj=size(img,2);
obj.datasize=[ni,nj,obj.datasize(3),obj.datasize(4)];

% flag
obj.flagRescaled=true;

end