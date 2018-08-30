function setBuffer(obj)
ni=obj.datasize(1);
nj=obj.datasize(2);

obj.bufferSize=50;
obj.bufferIndex=0;
obj.ImgBuffer=zeros(ni,nj,obj.bufferSize);
obj.BufferList=zeros(obj.bufferSize,1);

obj.flagSetBuffer=true;
end