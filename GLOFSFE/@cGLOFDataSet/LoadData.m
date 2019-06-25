%% load data 
function obj=LoadData(obj)
% check data before loading
if obj.flagDataChecked==false
    CheckData(obj);
end
% load necessary images
fprintf(1,'(%s) %s',obj.Name,'load dataset images...');

%% loading and averaging each calibration image set
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
    obj.CalImagesOrg.(fld{i})=obj.CalImages.(fld{i});
end

% median filtering selected cal image(s)
if ~isempty(obj.mfld)
    for k=1:size(obj.mfld,1)
        obj.CalImages.(obj.mfld{k})=...
            medfilt2(obj.CalImages.(obj.mfld{k}),[obj.n_med,obj.n_med],'symmetric');
    end
end

% make CalImages
% avoid bg becomes larger than dark in any case
if isempty(DirCal.bg)
    obj.CalImages.bg=max(obj.CalImages.dark,obj.CalImages.bg);
end

obj.CalImages.bg=obj.CalImages.bg-obj.CalImages.dark;
obj.CalImages.exc=obj.CalImages.exc-obj.CalImages.dark;

% calibrate alpha image
Texp=obj.CalPara.Texp;
exp_adj=Texp.alpha/Texp.bg; % exposure time adjustment

alpha=obj.CalImages.alpha-obj.CalImages.dark;
obj.CalImages.alpha=(alpha-obj.CalImages.bg.*exp_adj)./obj.CalImages.exc;

% offset image
exp_adj=Texp.run/Texp.bg; % exposure time adjustment
obj.CalImages.offset=obj.CalImages.bg*exp_adj;
obj.CalImages.denomi=obj.CalImages.exc;

% save original size CalImages
fld=fieldnames(obj.CalImages);
for i=1:size(fld,1)
    obj.CalImagesOrg.(fld{i})=obj.CalImages.(fld{i});
end

% returned to original size
obj.flagRescaled=false;


%% loading mask image

Dim=obj.oRuns{1}.Dim;
FileMask=obj.oCase.FileMask;

if isempty(FileMask)
    fprintf(1,' (mask is set to default)');
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

%% 
obj.flagImgLoaded=true;
% rescale images if it is set
if obj.flagRescale==true
    runRescaleRotCalMask(obj);
end
% obtaining calibration parameters alpha and beta
if obj.flagCalPara==true
    loadCalParaBeta(obj);
    loadCalParaAlpha(obj);
end

fprintf(1,'  %s\n','done');
end







