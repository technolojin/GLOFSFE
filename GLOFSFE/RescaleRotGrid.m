function [ Xq,Yq,CrdVtr_p ] = RescaleRotGrid( X,Y,CrdVtr,scale,angle )

% rotation center
p0=CrdVtr([1,2]);

% project to objective coordinate
[Xp,Yp]=RescaleRotCoor([max(X(:)),min(X(:)),max(X(:)),min(X(:))],...
           [max(Y(:)),max(Y(:)),min(Y(:)),min(Y(:))],scale,angle,p0);

% determine projection area
xd1=p0(1)-ceil(p0(1)-min(Xp(:)));
xd2=ceil(max(Xp(:))-p0(1))+p0(1);
yd1=p0(2)-ceil(p0(2)-min(Yp(:)));
yd2=ceil(max(Yp(:))-p0(2))+p0(2);

% objective mesh grid
[Ygq,Xgq]=meshgrid(yd1:1:yd2,xd1:1:xd2);
% obtaining query points (inverse projection)
[Xq,Yq]=RescaleRotCoor(Xgq,Ygq,1/scale,-angle,p0);

% coordinate vectors on projected area
if size(CrdVtr,1)==1
    CrdVtr(2,1)=CrdVtr(1,1)+1;
    CrdVtr(2,2)=CrdVtr(1,2);
end
CVgp=zeros(size(CrdVtr));
[CVgp(1,:),CVgp(2,:)]=...
    RescaleRotCoor(CrdVtr(1,:),CrdVtr(2,:),scale,angle,p0);
CrdVtr_p=zeros(size(CrdVtr));
CrdVtr_p(1,:)=CVgp(1,:)-xd1+min(X(:));
CrdVtr_p(2,:)=CVgp(2,:)-yd1+min(Y(:));

end

