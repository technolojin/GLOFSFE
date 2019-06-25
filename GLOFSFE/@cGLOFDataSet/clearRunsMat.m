function clearRunsMat(obj)
for r=1:size(obj.oRuns,1)
	obj.oRuns{r}.clearMat;
end
end

