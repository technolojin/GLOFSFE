function roi=getROI(obj)
if ~obj.flagImgLoaded
    LoadData(obj);
end

if isempty(obj.ROI)
    roi=obj.Mask;
else
    dim=size(obj.Mask);
    nw=size(obj.ROI,3);
    
    roi=zeros(dim(1),dim(2),nw);
    for n=1:nw
        R=obj.ROI(:,:,n).*obj.Mask;
        if sum(R(:))==0
            error('no effective roi');
        end
        roi(:,:,n)=R;
    end
end
end
