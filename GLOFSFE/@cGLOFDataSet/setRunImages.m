function setRunImages(obj)
CollectPairList(obj);
ni=obj.oRuns{1}.Dim(1);
nj=obj.oRuns{1}.Dim(2);
nk=size(obj.FileList,1);
np=size(obj.PairList,1);

obj.datasize=[ni,nj,nk,np];
obj.OrgDim=[ni,nj];
obj.max_image=obj.oRuns{1}.max_image;
end