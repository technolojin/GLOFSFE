function [ In2 ] = RescaleRot( In1,scale,angle,rotcenter,use_gpu)
%RescaleRot
% rescaling and rotationg image by interp2
%
% scale: ratio of rescaling
% angle[deg]: rotationg angle (clock wise)
% rotcenter = [xc,yc]: center position
%
% %%%%%coordinate system%%%%%
% zero position: on left top
% x-axis: top to bottom
% y-axis: left to right

narginchk(2,5);

if scale==0
    error('scale cannot be 0');
end

[ni,nj,nk]=size(In1);
if nargin<3
    angle=0;
end
if nargin<4
    rotcenter=[ni/2,nj/2];
end
if isempty(rotcenter)
    rotcenter=[ni/2,nj/2];
end
if nargin<5
    use_gpu=0;
end
if nargin>5
    error('input error');
end

if (angle==0)&&(scale==1)
    In2=In1;
else
    % original mesh grid  
    [Y,X]=meshgrid(1:nj,1:ni);
        
    % project to objective coordinate
    [Xq,Yq,~] = RescaleRotGrid( X,Y,rotcenter,scale,angle );
    
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
        In2(:,:,i)=interp2(Y,X,In1(:,:,i),Yq,Xq,'linear');
    end
end
end
