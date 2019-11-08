function [ h ] = quiver_mod(varargin)

[~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
narginchk(2,inf);

if isempty(cax) || ishghandle(cax,'axes')
	cax= newplot(cax);
end
% Parse remaining args
try
    dirname=fullfile(matlabroot, 'toolbox\matlab\specgraph\private');
    oldDir = pwd;
    cd(dirname);
    pvpairs = quiverparseargs(args);
    
    cd(oldDir);
catch ME
    throw(ME)
end


nu = 30;
offset = 1;

idx=0;
args_rem={};
X=[];
Y=[];
while idx<numel(pvpairs)
    idx=idx+1;
    if strcmp(pvpairs{idx},'vectorNumber')
        nu =pvpairs{idx+1};
        idx=idx+1;
    elseif strcmp(pvpairs{idx},'Offset')
        offset =pvpairs{idx+1};
        idx=idx+1;
    elseif strcmp(pvpairs{idx},'XData')
        X =pvpairs{idx+1};
        idx=idx+1;
    elseif strcmp(pvpairs{idx},'YData')
        Y =pvpairs{idx+1};
        idx=idx+1;
    elseif strcmp(pvpairs{idx},'UData')
        U =pvpairs{idx+1};
        idx=idx+1;
    elseif strcmp(pvpairs{idx},'VData')
        V =pvpairs{idx+1};
        idx=idx+1;
    else
        args_rem=[args_rem,pvpairs{idx}];
    end
end

[ny,nx]=size(U);
if isempty(X)||isempty(Y)
    [X,Y]=meshgrid(1:nx,1:ny);
    xlim=[1,nx];
    ylim=[1,ny];
    length = 1.5;
else
    xlim=[min(X(:)),max(X(:))];
    ylim=[min(Y(:)),max(Y(:))];
    length = min((xlim(2)-xlim(1))/nx,(ylim(2)-ylim(1))/ny)*1.5;
end

% set skip number
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
imgq = plot.imgQuantile(I, stdp);
v_max=imgq/stdp;

nk=size(C,1);
Ic = round(I/v_max*(nk-1))+1;
Ic(Ic>=nk)=nk;

Unorm=U./I*length*skp;
Vnorm=V./I*length*skp;

% mag=1.5*skp/v95;

%%
hold on;
h=cell(nk,1);
for k=1:nk
    idx=find(double(Ic(:)==k).*Mskip(:));
    h{k}=quiver(cax,X(idx),Y(idx),Unorm(idx),Vnorm(idx),0,'Color',[0,0,0],'LineWidth',2);
    h{k}=quiver(cax,X(idx),Y(idx),Unorm(idx),Vnorm(idx),0,'Color',C(k,:),args_rem{:});
end
set(cax,'Color','black','XLim',xlim,'YLim',ylim);
hold off;



end

