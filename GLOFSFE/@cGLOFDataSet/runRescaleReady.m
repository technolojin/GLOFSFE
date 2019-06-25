function runRescaleReady(obj,CrdVtr,scale,angle,use_gpu)

if nargin==4
    use_gpu=false;
end

Dim=obj.OrgDim;
ni=Dim(1);
nj=Dim(2);

if isempty(CrdVtr)
    CrdVtr=[ni/2;nj/2];
end

% original mesh grid
[Y,X]=meshgrid(1:nj,1:ni);
% project to objective coordinate
[Xq,Yq,CrdVtr_p]=RescaleRotGrid(X,Y,CrdVtr,scale,angle );

obj.QueryGrid=cell(4,1);
if use_gpu
    obj.QueryGrid{1}=gpuArray(X);
    obj.QueryGrid{2}=gpuArray(Y);
    obj.QueryGrid{3}=gpuArray(Xq);
    obj.QueryGrid{4}=gpuArray(Yq);
    obj.flagRescaleReady=false;
    obj.flagRescaleReadyGpu=true;
else
    obj.QueryGrid{1}=X;
    obj.QueryGrid{2}=Y;
    obj.QueryGrid{3}=Xq;
    obj.QueryGrid{4}=Yq;
    obj.flagRescaleReady=true;
    obj.flagRescaleReadyGpu=false;
end

obj.CalPara.CrdVtr_p=CrdVtr_p;

obj.flagRescaleReady=true;
end

