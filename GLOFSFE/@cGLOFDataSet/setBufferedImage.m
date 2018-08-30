function setBufferedImage(obj,img,nk)
obj.bufferIndex=obj.bufferIndex+1;
if obj.bufferIndex>obj.bufferSize
    obj.bufferIndex=obj.bufferIndex-obj.bufferSize;
end
obj.ImgBuffer(:,:,obj.bufferIndex)=img;
obj.BufferList(obj.bufferIndex)=nk;
end