function clearTemps(obj)
obj.ImgBuffer=[];
obj.flagSetBuffer=false;
for r=1:size(obj.oRuns,1)
    obj.oRuns{r}.clearMat;
end
end