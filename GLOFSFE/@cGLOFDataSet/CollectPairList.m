function CollectPairList(obj)
% load and merge multiple run object
nr=max(size(obj.oRuns));
npl=zeros(nr,1); % pair numbers
nfl=zeros(nr,1); % file numbers
for r=1:nr
    npl(r)=obj.oRuns{r}.np;
    nfl(r)=obj.oRuns{r}.Dim(3);
end
nallpl=sum(npl);
nallfl=sum(nfl);

allpl=zeros(nallpl,4);
allfl=zeros(nallfl,2);

idx_pl=0;
idx_fl=0;
for r=1:nr
    allpl(idx_pl+1:idx_pl+npl(r),1)=r;
    allpl(idx_pl+1:idx_pl+npl(r),2:3)=obj.oRuns{r}.PairLists;
    allpl(idx_pl+1:idx_pl+npl(r),4)=...
        obj.oRuns{r}.PairLists(2)-obj.oRuns{r}.PairLists(1);
    
    allfl(idx_fl+1:idx_fl+nfl(r),1)=r;
    allfl(idx_fl+1:idx_fl+nfl(r),2)=1:nfl(r);
    
    idx_pl=idx_pl+npl(r);
    idx_fl=idx_fl+nfl(r);
end

obj.PairList=allpl;
obj.FileList=allfl;

end