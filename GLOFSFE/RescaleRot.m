function [ In2 ] = RescaleRot( In1,scale,angle,yc,xc)
%RescaleRot
% rescaling and rotationg by interp2
%
% scale: ratio of rescaling
% angle[deg]: rotationg angle (clock wise)
% xc,yc: center position
% zero position is on left top
% x-axis: right to left
% y-axis: top to bottom

narginchk(2,5);

if scale==0
    error('scale cannot be 0');
end

[nj,ni,nk]=size(In1);
if nargin==2
    angle=0;
    xc=ni/2;
    yc=nj/2;
elseif nargin==3
    xc=ni/2;
    yc=nj/2;
elseif nargin>5
    error('input error');
end

if (angle==0)&&(scale==1)
    In2=In1;
else
    xd1=ceil(-(xc-0.5)*scale+xc);
    xd2=floor((ni-0.5-xc)*scale+xc);
    yd1=ceil(-(yc-0.5)*scale+yc);
    yd2=floor((nj-0.5-yc)*scale+yc);
    
    [X,Y]=meshgrid(0.5:ni-0.5,0.5:nj-0.5);
    [Xq,Yq]=meshgrid(xd1+0.5:xd2-0.5,yd1+0.5:yd2-0.5);
    
    Rq=sqrt((Xq-xc).^2+(Yq-yc).^2);
    Tq=atan2((Yq-yc),(Xq-xc));
    Rq=Rq./scale;
    Tq=Tq+angle/180*pi();
    Xq=xc+Rq.*cos(Tq);
    Yq=yc+Rq.*sin(Tq);
    [niq,njq]=size(Xq);
    In1=double(In1);
    In2=zeros(niq,njq,nk);
    
    for i=1:nk
        I1=interp2(X,Y,In1(:,:,i),Xq,Yq,'linear');
        In2(:,:,i)=I1;
    end
    
    In2(isnan(In2))=0;
end

end

