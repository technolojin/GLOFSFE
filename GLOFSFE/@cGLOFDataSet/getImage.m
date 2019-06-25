function img=getImage(obj,nr,nk,use_gpu)
% nr: run index
% nk: image index in the run

% load data
if obj.flagImgLoaded==false
    obj.LoadData();
end
% set image buffer
if (use_gpu==true)&&(obj.flagSetGpuBuffer==false)
    setBuffer(obj,use_gpu);
elseif (use_gpu==false)&&(obj.flagSetBuffer==false)
    setBuffer(obj,use_gpu);
end

list=(obj.FileList(:,1)==nr)&(obj.FileList(:,2)==nk);
fileidx=find(list,1);
% find image index
idx=getBufferedIndex(obj,fileidx);

if idx==0  % if buffered image is not exist
    img=obj.oRuns{nr}.getI(nk);
    % load to gpu memory
    if use_gpu==true
        img=gpuArray(img);
    end
    % median filter
    img=medfilt2(img,[3,3]);
    % rescale 
    if obj.flagRescale
        img=obj.runRescaleRot(img,use_gpu);
    end
    % ratioed image
    img=(img-obj.CalImgBuffer.offset)./obj.CalImgBuffer.denomi;
    img(img<0)=0;
    % set image to buffer
    setBufferedImage(obj,img,fileidx);
else
    % load buffered image
    img=obj.ImgBuffer(:,:,idx);
end

end