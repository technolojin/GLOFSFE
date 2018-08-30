function img=getImage(obj,nr,nk)
% nr: run index
% nk: image index in the run
if obj.flagSetBuffer==false
    setBuffer(obj);
end
list=(obj.FileList(:,1)==nr)&(obj.FileList(:,2)==nk);
fileidx=find(list,1);

idx=getBufferedIndex(obj,fileidx);
if idx==0
    img=obj.oRuns{nr}.getI(nk);
    if obj.flagRescale
        img=RescaleRot(img,obj.CalPara.scale,obj.CalPara.angle);
    end
    img=(img-obj.CalImages.bg)./obj.CalImages.exc;
    setBufferedImage(obj,img,fileidx);
else
    img=obj.ImgBuffer(:,:,idx);
end
end