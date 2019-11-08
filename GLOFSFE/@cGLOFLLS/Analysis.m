function Analysis( obj, varargin )
%Rsq Coefficient of determination "R squared"
%
%SYNOPSIS:
%
%
%INPUT:
%   oDataSet: cGLOFDataSet object
%   option: (opt) set 'gpu' if want to use 'Parallel Computing Toolbox'
%
%OUTPUT:
%
%
%See also:
% cGLOFDataSet
% gpuArray
% <a href="https://doi.org/10.1063/1.5001388">Taekjin Lee, Taku Nonomura,
%   Keisuke Asai, and Tianshu Liu, "Linear least-squares method for global
%   luminescent oil film skin friction field analysis", Review of
%   Scientific Instruments 89, 065106 (2018)</a>
%
%
% Copyright (c) 2018 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php


narginchk(1,2);
use_gpu = ComputingOpt(varargin{:});

oDataSet=obj.oDataSet;
PairMask=obj.PairMask;
tau=obj.tau;
bAve=obj.bAve;
Uave=obj.Uave;

Scell=ones(1);

%% dataset
if oDataSet.flagImgLoaded==false
    oDataSet.LoadData();
end

datasize=oDataSet.datasize;
ni=datasize(1);
nj=datasize(2);
nk=datasize(4);

roi=obj.roi.img;
nW=size(roi,3);

%% Temporal Mask
if size(PairMask,1)~=nk
    error('PairMask size is not matching.');
elseif size(PairMask,2)==1
    PairMask=repmat(PairMask,[1,nW]);
elseif size(PairMask,2)~=nW
    error('PairMask size is not matching.');
end

listk=find(sum(PairMask,2));
nkw=sum(PairMask,1);
nke=size(listk(:),1);

%% scheme and initial matrices
% multiple roi (in 3rd dim)

cA1=cell(nW,1);
cB1=cell(nW,1);
cBave=cell(nW,1);
cRSS=cell(nW,1);
cTSS=cell(nW,1);
cResMeff=cell(nW,1);

% scheme matrices
[ Mave,Mc2f,SumFlux,Msigma,Diff_x,Diff_t ]=obj.fScheme( ni,nj,Scell );

for w=1:nW
    
    [ resMeff,~,~,~,~ ] = obj.fEffMat( Mc2f,SumFlux,Msigma,Diff_x,roi(:,:,w) );
    
    A1=resMeff*Msigma*SumFlux*Diff_x;
    A2=Mc2f*Mave;
    B1=resMeff*Msigma*Diff_t;
       
    % initialization
    nF=size(A2,1);
    nQ=size(B1,1);
    
    Bave=bAve{w};
    RSS=zeros(nQ,1);
    TSS=zeros(nQ,1);
    
    % send to gpu memory
    if use_gpu==1
        A1=gpuArray(A1);
        B1=gpuArray(B1);
        RSS=gpuArray(RSS);
        TSS=gpuArray(TSS);
        Bave=gpuArray(Bave);
    end
    
    % contain in cells
    cA1{w}=A1;
    cB1{w}=B1;
    cBave{w}=Bave;
    cRSS{w}=RSS;
    cTSS{w}=TSS;
    cResMeff{w}=resMeff;
end

% empty matrices
Urms=zeros(ni-1,nj-1,2);

img_ave=obj.img.ave;
img_min=ones(ni,nj)*Inf;
img_max=zeros(ni,nj);
img_rms=zeros(ni,nj);

% send to gpu memory
if use_gpu==1
    Uave=gpuArray(Uave);
    Urms=gpuArray(Urms);
    img_ave=gpuArray(img_ave);
    img_min=gpuArray(img_min);    
    img_max=gpuArray(img_max);    
    img_rms=gpuArray(img_rms);    
end

%% loading images and calculate LLS matrix
fprintf(1,'%s %5.1f%%','Analyse LLS: ',0);
kidx=0;

for k=1:nk
    
    if ~any(listk==k)
        continue
    end
    kidx=kidx+1;
    fprintf(1,'\b\b\b\b\b\b');
    fprintf(1,'%5.1f%%',kidx/nke*100);
    
    [h1,h2]=oDataSet.getPair(k,use_gpu);
    
    h=[h1(:);h2(:)];
    
    % LLS
    hf=A2*h;
    hh=sparse(1:nF,1:nF,hf.*hf/2,nF,nF);
    for w=1:nW
        if ~PairMask(k,w)
            continue
        end
        Ak=cA1{w}*hh;
        Bk=cB1{w}*h;
        
        Best=Ak*tau(:,w);
        cRSS{w}=cRSS{w}+(Best+Bk).^2;
        cTSS{w}=cTSS{w}+(Bk-cBave{w}).^2;
    end
    
    % image
    hk=(h1+h2)./2;
    img_rms=img_rms+(hk-img_ave).^2;
    img_min=min(img_min,hk);
    img_max=max(img_max,hk);   
    
    % optical flow
    [ Ux,Uy ] = obj.fOpticalFlow( h1, h2 );
    Urms(:,:,1)=Urms(:,:,1)+(Uave(:,:,1)-Ux).^2;
    Urms(:,:,2)=Urms(:,:,2)+(Uave(:,:,2)-Uy).^2;
    
end

Urms=(Urms./nke).^0.5;
img_rms=sqrt(img_rms./nke);

if use_gpu==1
    Urms=gather(Urms);
    img_max=gather(img_max);
    img_min=gather(img_min);
    img_rms=gather(img_rms);
end

%% Rsq
Rsq=zeros(ni-1,nj-1,nW);
for w=1:nW
    RSS=cRSS{w};
    TSS=cTSS{w};
    resMeff=cResMeff{w};

    if use_gpu==1
        RSS=gather(RSS);
        TSS=gather(TSS);
    end
    
    nQ=size(resMeff,1);
    rsq=resMeff'*(ones(nQ,1)-RSS./TSS);
    
    rsq(isnan(rsq))=0;
    rsq(isinf(rsq))=0;
        
    Rsq(:,:,w)=reshape(rsq,ni-1,nj-1);
end

%% analysis results
obj.Rsq=single(Rsq);
obj.Urms=single(Urms);
obj.img.max=single(img_max);
obj.img.min=single(img_min);
obj.img.rms=single(img_rms);

fprintf(1,'  %s \n','done');

end

