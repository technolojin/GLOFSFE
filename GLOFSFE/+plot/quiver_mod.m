function [ h ] = quiver_mod(U,V,nu,offset,varargin)
%QUIVER_MOD 
if (nargin<3)
	nu = 30;
end
if (nargin<4)
	offset = 1;
end

length = 1.5;


[ny,nx]=size(U);
[X,Y]=meshgrid(1:nx,1:ny);

% set skin number
if nu>=nx||nu>=ny
    skp=1;
elseif nu<=5
    skp=min(floor((nx-offset)/5),floor((ny-offset)/5));
else
    skp=min(floor(nx/nu),floor(ny/nu));
end

Mskip=zeros(ny,nx);
Mskip(offset:skp:end, offset:skp:end)=1;

% each vector is averaged one of surroundings
U=conv2(U,ones(skp)/skp.^2,'same');
V=conv2(V,ones(skp)/skp.^2,'same');
%%
colormap jet;
C = colormap;

I = sqrt(U.^2 + V.^2);

% Quantile of 'stdp' to the range
stdp=0.95;
% temp=sort(nonzeros(I(:)));
% nt=size(temp,1);
% v_max=temp(floor(nt*stdp))/stdp;
imgq = plot.imgQuantile(I, stdp);
v_max=imgq/stdp;

nk=size(C,1);
Ic = round(I/v_max*(nk-1))+1;
Ic(Ic>=nk)=nk;

Unor=U./I*length*skp;
Vnor=V./I*length*skp;

% mag=1.5*skp/v95;

%%
hold on;
h=cell(nk,1);
for k=1:nk
    idx=find(double(Ic(:)==k).*Mskip(:));
    h{k}=quiver(X(idx),Y(idx),Unor(idx),Vnor(idx),0,'Color',[0,0,0],'LineWidth',2);
    h{k}=quiver(X(idx),Y(idx),Unor(idx),Vnor(idx),0,'Color',C(k,:),varargin{:});
end
set(gca,'Color','black','XLim',[1,nx],'YLim',[1,ny]);
hold off;



end

