function runRescaleRotImages(obj)
% cal images
fld=fieldnames(obj.CalImages);
nk=size(fld,1);
for k=1:nk
    img=RescaleRot(obj.CalImages.(fld{k}),obj.CalPara.scale,obj.CalPara.angle);
    %img(isnan(img))=0;
    obj.CalImages.(fld{k})=img;
end
% masks
img=double(obj.Mask);
img=RescaleRot(img,obj.CalPara.scale,obj.CalPara.angle);
obj.Mask=img>0.5;

% update datasize
[ni,nj]=size(img);
obj.datasize=[ni,nj,obj.datasize(3),obj.datasize(4)];

% flag
obj.flagRescaled=true;

if obj.flagCalPara
    setCalPara(obj);
end
end