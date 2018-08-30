function idx=getBufferedIndex(obj,nk)
list=obj.BufferList==nk;
idx=find(list,1);
if isempty(idx)
    idx=0;
end
end