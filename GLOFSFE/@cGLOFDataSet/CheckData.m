function CheckData( obj )
% check image size
OrgDim=CheckImageSize(obj);

% check rescalerot grid
if obj.flagRescale==true
    scale=obj.CalPara.scale;
    angle=obj.CalPara.angle;
    CrdVtr=obj.CalPara.CrdVtr;
    runRescaleReady(obj,CrdVtr,scale,angle); 
    
    Xq=obj.QueryGrid{3};
    ResDim=size(Xq);
else
    ResDim=OrgDim;
end

% check ROI
if ~isempty(obj.ROI)
    roiDim=size(obj.ROI);
    roiDim=roiDim([1,2]);
    if ~isequal(OrgDim,roiDim)&&~isequal(ResDim,roiDim)
        error('ROI size is not matching');
    end
end

obj.OrgDim=OrgDim;
obj.ResDim=ResDim;
obj.flagDataChecked=true;
end

%%

function Dim=CheckImageSize(obj)
% check all run images
nRun=size(obj.oRuns(:),1);
runDim=obj.oRuns{1}.Dim([1,2]); % from run images
for n=1:nRun
    runDim_n=obj.oRuns{n}.Dim([1,2]);
    if ~isequal(runDim,runDim_n)
        error('run image size is not matching');
    end
end

% check cal images
DirCal=obj.oCase.DirCal;
max_calimage=obj.oCase.max_image;
fmt=obj.oCase.cal_fmt;
fld=fieldnames(obj.oCase.DirCal);
for i=1:size(fld,1)
    if ~isempty(DirCal.(fld{i}))
        img=cGLOFImageSet(DirCal.(fld{i}),fmt,max_calimage);
        calDim=img.Dim([1,2]);
        if ~isequal(runDim,calDim)
            error('cal image size is not matching');
        end
    end
end

% check mask image
FileMask=obj.oCase.FileMask;
if ~isempty(FileMask)
    if ischar(FileMask)
        mask=LoadImages(FileMask);
        maskDim=size(mask);
    elseif isnumeric(FileMask)||islogical(FileMask)
        maskDim=size(FileMask);
        maskDim=maskDim(1:2);
    end
    if ~isequal(runDim,maskDim)
        error('mask image size is not matching');
    end
end

Dim=runDim;
end