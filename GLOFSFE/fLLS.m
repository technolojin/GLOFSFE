function [ tau_x, tau_y ] = fLLS( oDataSet, option )
%FLLS process a dataset to get skin friction field.
%
%SYNOPSIS:
% [ tau_x, tau_y ] = fLLS( A ) 
% [ tau_x, tau_y ] = fLLS( A, 'gpu') 
%
%INPUT:
%   oDataSet: cGLOFDataSet object
%   option: (opt) set 'gpu' if want to use 'Parallel Computing Toolbox'
%
%OUTPUT:
%   tau_x, tau_y: estimated skin friction field
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

if nargin==1
    use_gpu=0;
else
    if option=='gpu'
        use_gpu=1;
        disp('use GPGPU');
    elseif option=='cpu'
        use_gpu=0;
    else
        error('invalid method');
    end
end

Scell=ones(1);

%% dataset
if oDataSet.flagImgLoaded==false
    oDataSet.LoadData();
end

datasize=oDataSet.datasize;
ni=datasize(1);
nj=datasize(2);
nk=datasize(4);

roi=oDataSet.Mask;

%% scheme 3
% tau vector follows face ni*nj
% flux follows face ni*nj
% residual unit around node (ni-1)*(nj-1)
nM=ni*nj;
nP=(ni-1)*(nj-1);

% time average
Mave=[spdiags(ones(nM,1),0,nM,nM),spdiags(ones(nM,1),0,nM,nM)]/2;

% cell to flux
f_c2f=rot90([1,1;0,0]/2,2);
Mc2f=[convmtx2_mod(f_c2f ,ni,nj,'same');convmtx2_mod(f_c2f',ni,nj,'same')];

% spatial differential scheme, 
% summarize 2 Directions into one residual unit 
f_diff=rot90([-1,0;1,0],2);
Diff_x=[convmtx2_mod(f_diff ,ni,nj,'valid'),sparse(nP,nM);...
            sparse(nP,nM),convmtx2_mod(f_diff',ni,nj,'valid')];
SumFlux=[spdiags(ones(nP,1),0,nP,nP),spdiags(ones(nP,1),0,nP,nP)];

% time differential scheme, average on one cell 
Mc2n=convmtx2_mod(ones(2)/4,ni,nj,'valid');
Diff_t=[-Mc2n,Mc2n];

% cell to residual integral matrix
Msigma=convmtx2_mod(rot90(Scell,2),ni-1,nj-1,'valid');

% effective residual unit
roi_c=abs(SumFlux*Diff_x)*Mc2f*roi(:)==4;    

% effective residuals matrix 
effRes=Msigma*roi_c(:);
effRes=effRes==sum(Scell(:));
nQ=size(effRes(:),1);
resMeff=spdiags(effRes(:),0,nQ,nQ);

effVec=abs(Diff_x'*SumFlux')*Msigma'*effRes;
effVec=effVec>0;

Meff = rdmtx( effVec );

%%
A1=resMeff*Msigma*SumFlux*Diff_x;
A2=Mc2f*Mave;
A3=Meff';
B1=resMeff*Msigma*Diff_t;

nNeff=size(A3,2);
nF=size(A2,1);

C=sparse(1,1,0,nNeff,nNeff);
d=zeros(nNeff,1);

if use_gpu==1
    A1=gpuArray(A1);
    A2=gpuArray(A2);
    A3=gpuArray(A3);
    B1=gpuArray(B1);  
    C=gpuArray(C);
    d=gpuArray(d);
end

%%  loading images and LLS matrix

fprintf(1,'%s %5.1f%%','load LLS matrix : ',0);
for k=1:nk
    fprintf(1,'\b\b\b\b\b\b');
    fprintf(1,'%5.1f%%',k/nk*100);
    
    [h1,h2]=oDataSet.getPair(k);
    
    h=[h1(:);h2(:)];
    if use_gpu==1
        h=gpuArray(h);
    end
    hf=A2*h;
    hh=sparse(1:nF,1:nF,hf.*hf/2,nF,nF);
    
    Ak=A1*hh*A3;    
    Bk=B1*h;
    
    % add sparse
    C=C+Ak'*Ak;
    d=d+Ak'*Bk;
    
end

if use_gpu==1
    C=gather(C);
    d=gather(d);
end

%% LLS
fprintf(1,['\n','calculate LLS...\n']);
spparms('spumoni',1);
%C(end,end-1)=1E-20; % trick to select UMFPACK solver

tau_eff=-(C)\(d);
tau=Meff'*tau_eff;
tau=reshape(tau,[ni nj 2]);

tau_x=tau(:,:,1);
tau_y=tau(:,:,2);

% vectors to node-center
mask_node=conv2(double(roi),ones(2),'valid');
mask_node=mask_node==4;
f_v2n=[0,1;0,1]/2;
tau_x=conv2(tau_x,f_v2n ,'valid').*mask_node;
tau_y=conv2(tau_y,f_v2n','valid').*mask_node;

fprintf(1,'%s \n','done');

end

