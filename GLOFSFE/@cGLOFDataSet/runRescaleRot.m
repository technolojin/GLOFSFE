function [ In2 ] = runRescaleRot( obj, In1, use_gpu )

[ni,nj,nk]=size(In1);

scale=obj.CalPara.scale;
angle=obj.CalPara.angle;
CrdVtr=obj.CalPara.CrdVtr;

if isempty(CrdVtr)
    CrdVtr=[ni/2;nj/2];
end

if (angle==0)&&(scale==1)
    In2=In1;
else
       
    if (use_gpu==true)&&(obj.flagRescaleReadyGpu==false)
        runRescaleReady(obj,CrdVtr,scale,angle,use_gpu);
    elseif (use_gpu==false)&&(obj.flagRescaleReady==false)
        runRescaleReady(obj,CrdVtr,scale,angle,use_gpu);
    end
    
    % load query grid
    X=obj.QueryGrid{1};
    Y=obj.QueryGrid{2};
    Xq=obj.QueryGrid{3};
    Yq=obj.QueryGrid{4};
    
    % initialization
    [niq,njq]=size(Yq);
    In1=double(In1);
    if use_gpu==1
        In2=gpuArray(zeros(niq,njq,nk));
    else
        In2=zeros(niq,njq,nk);
    end
    
    % interpolation 
    for i=1:nk
        In2(:,:,i)=interp2(Y,X,In1(:,:,i),Yq,Xq,'linear',0);
    end

end

end

