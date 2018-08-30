%%
% loading and averaging each calibration image set
function LoadCalImages(obj)
Dim=obj.oRuns{1}.Dim;
DirCal=obj.oCase.DirCal;
max_calimage=obj.oCase.max_image;
fmt=obj.oCase.cal_fmt;
fld=fieldnames(obj.oCase.DirCal);

for i=1:size(fld,1)
    if ~isempty(DirCal.(fld{i}))
        img=cGLOFImageSet(DirCal.(fld{i}),fmt,max_calimage);
        obj.CalImages.(fld{i})=getIave(img);
    else
        if strcmp(fld{i},'exc')
            obj.CalImages.(fld{i})=ones(Dim(1),Dim(2));
        else
            obj.CalImages.(fld{i})=zeros(Dim(1),Dim(2));
        end
    end
end

% median filtering selected cal image(s)
if ~isempty(obj.mfld)
    for k=1:size(obj.mfld,1)
        obj.CalImages.(obj.mfld{k})=...
            medfilt2(obj.CalImages.(obj.mfld{k}),[obj.n_med,obj.n_med],'symmetric');
    end
end

% calibrate alpha image
obj.CalImages.alpha=(obj.CalImages.alpha-obj.CalImages.bg)./obj.CalImages.exc;
obj.CalImagesOrg.alpha=obj.CalImages.alpha;
end
