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

roi=oDataSet.getROI();

%% scheme and initial matrices
% multiple roi (in 3rd dim)
nW=size(roi,3);
cA1=cell(nW,1);
cB1=cell(nW,1);
cBave=cell(nW,1);
cRSS=cell(nW,1);
cTSS=cell(nW,1);

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
for k=1:nk
    fprintf(1,'\b\b\b\b\b\b');
    fprintf(1,'%5.1f%%',k/nk*100);
    
    [h1,h2]=oDataSet.getPair(k,use_gpu);
    
    h=[h1(:);h2(:)];
    
    % LLS
    hf=A2*h;
    hh=sparse(1:nF,1:nF,hf.*hf/2,nF,nF);
    for w=1:nW
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

Urms=(Urms./nk).^0.5;
img_rms=sqrt(img_rms./nk);

if use_gpu==1
    Urms=gather(Urms);
    img_max=gather(img_max);
    img_min=gather(img_min);
    img_rms=gather(img_rms);
end

%% Rsq
Rsq=zeros(ni,nj,nW);
for w=1:nW
    RSS=cRSS{w};
    TSS=cTSS{w};
    B1=cB1{w};
    
    nQ=size(B1,1);
    
    rsq=B1'*(ones(nQ,1)-RSS./TSS);
    rsq=-rsq(1:nF/2);
    
    if use_gpu==1
        rsq=gather(rsq);
    end
    
    rsq(isnan(rsq))=0;
    rsq(isinf(rsq))=0;
        
    Rsq(:,:,w)=reshape(rsq,ni,nj);
end

%% analysis results
obj.Rsq=Rsq;
obj.Urms=Urms;
obj.img.max=img_max;
obj.img.min=img_min;
obj.img.rms=img_rms;

fprintf(1,'  %s \n','done');

end

