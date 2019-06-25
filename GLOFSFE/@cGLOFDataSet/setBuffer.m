function setBuffer(obj,use_gpu)
ni=obj.datasize(1);
nj=obj.datasize(2);

obj.bufferSize=20;
obj.bufferIndex=0;
obj.ImgBuffer=zeros(ni,nj,obj.bufferSize);
obj.BufferList=zeros(obj.bufferSize,1);

% set calimage buffer: offset, denomi
obj.CalImgBuffer=struct('offset',obj.CalImages.offset,...
    'denomi',obj.CalImages.denomi);

% GpuBuffer
if use_gpu
    obj.ImgBuffer=gpuArray(obj.ImgBuffer);
    obj.CalImgBuffer.offset=gpuArray(obj.CalImgBuffer.offset);
    obj.CalImgBuffer.denomi=gpuArray(obj.CalImgBuffer.denomi);
    obj.flagSetBuffer=false;
    obj.flagSetGpuBuffer=true;
else
    obj.flagSetBuffer=true;
    obj.flagSetGpuBuffer=false;
end

end