% rescaling and rotating images
function setRescaleRot(obj,scale,angle,CrdVtr)

narginchk(2,4);
if scale==0
    error('scale cannot be 0');
end
if nargin<3
    angle=0;
end
if nargin<4
    CrdVtr=[];
end

obj.CalPara.scale=scale;
obj.CalPara.angle=angle;
obj.CalPara.CrdVtr=CrdVtr;

obj.flagRescale=true;
obj.flagRescaleReady=false;
obj.flagRescaled=false;
obj.flagImgLoaded=false;
obj.flagDataChecked=false;

clearTemps(obj);

end