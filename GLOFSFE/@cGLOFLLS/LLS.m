function LLS( obj, use_gpu )
%LLS process a dataset to get skin friction field.
%
%SYNOPSIS:
% LLS( cGLOFLLS, false )
% LLS( cGLOFLLS, true )
%
%INPUT:
%   cGLOFLLS: cGLOFLLS object
%   use_gpu: set true if want to use 'Parallel Computing Toolbox'
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
% Copyright (c) 2019 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php


%% inputs
oDataSet=obj.oDataSet;
PairMask=obj.PairMask;
Scell=ones(1);

%% dataset
if oDataSet.flagImgLoaded==false
    oDataSet.LoadData();
end

datasize=oDataSet.datasize;
ni=datasize(1);
nj=datasize(2);
nk=datasize(4);

roi_img=oDataSet.getROI();
nW=size(roi_img,3);

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

% roi
roi_node=true(ni-1,nj-1,nW);
roi_cell=true(ni-1,nj-1,nW);
roi_tau_x=true(ni,nj,nW);
roi_tau_y=true(ni,nj,nW);
            
for w=1:nW
    roi_n=conv2(single(roi_img(:,:,w)),ones(2),'valid');
    roi_n=roi_n==4;
    roi_node(:,:,w)=roi_n;
end


% initial cells of matrices
cA1=cell(nW,1);
cA3=cell(nW,1);
cA1T=cell(nW,1);
cA3T=cell(nW,1);
cB1=cell(nW,1);
cBave=cell(nW,1);
cC=cell(nW,1);
cd=cell(nW,1);

% get scheme matrices
[ Mave,Mc2f,SumFlux,Msigma,Diff_x,Diff_t ]=obj.fScheme( ni,nj,Scell );

for w=1:nW
    
    % get effective dimension matrices
    [ resMeff,Meff,roi_node(:,:,w),roi_tau_x(:,:,w),roi_tau_y(:,:,w),roi_cell(:,:,w)]=...
        obj.fEffMat( Mc2f,SumFlux,Msigma,Diff_x,roi_img(:,:,w) );
    
    A1=resMeff*Msigma*SumFlux*Diff_x;
    A2=Mc2f*Mave;
    A3=Meff';
    B1=resMeff*Msigma*Diff_t;
    clear('resMeff','Meff');

    % initialization
    nNeff=size(A3,2);
    nF=size(A2,1);
    nQ=size(B1,1);
    
    C=sparse(1,1,0,nNeff,nNeff);
    d=zeros(nNeff,1);
    Bave=zeros(nQ,1);

    % send to gpu memory
    if use_gpu
        A1=gpuArray(A1);
        A3=gpuArray(A3);
        B1=gpuArray(B1);
        C=gpuArray(C);
        d=gpuArray(d);
        Bave=gpuArray(Bave);
    end
    
    % contain in cells
    cA1{w}=A1;
    cA3{w}=A3;
    cA1T{w}=A1';
    cA3T{w}=A3';
    cB1{w}=B1;
    cBave{w}=Bave;
    cC{w}=C;
    cd{w}=d;
    
    clear('A1','A3','B1','Bave','C','d');
    
end

% local
Clocal=zeros(ni-1,nj-1,3);
dlocal=zeros(ni-1,nj-1,2);
tau_local=zeros(ni-1,nj-1,2);
% optical flow
U=zeros(ni-1,nj-1,2);
img_ave=zeros(ni,nj);

% send to gpu memory
if use_gpu
    A2=gpuArray(A2);
    Clocal=gpuArray(Clocal);
    dlocal=gpuArray(dlocal);
    tau_local=gpuArray(tau_local);
    U=gpuArray(U);
    img_ave=gpuArray(img_ave);
end

%% loading images and calculate LLS matrices
fprintf(1,'%s %5.1f%%','Load images and calculate LLS matrices: ',0);
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
    img_ave=img_ave+(h1+h2);
    
    hf=A2*h;
    hh=sparse(1:nF,1:nF,hf.*hf/2,nF,nF);
    
    % on each roi
    for w=1:nW
        if ~PairMask(k,w)
            continue
        end
        Ak=cA1{w}*hh*cA3{w};
        AkT=cA3T{w}*hh*cA1T{w};
        Bk=cB1{w}*h;
        
        % accumulate LLS matrix
        cC{w}=cC{w}+AkT*Ak;
        cd{w}=cd{w}+AkT*Bk;
        
        %b vector averaging
        cBave{w}=cBave{w}+Bk;
    end
    
    % local filtering method
    hm=(h1+h2)/2;
    hhm=(hm.^2)/2;
    hhx=conv2(hhm,[1,1;-1,-1]/2,'valid');
    hhy=conv2(hhm,[1,-1;1,-1]/2,'valid');
    ht=conv2(-h1+h2,ones(2)/4,'valid');
    
    Clocal(:,:,1)=Clocal(:,:,1)+hhx.^2  ;
    Clocal(:,:,2)=Clocal(:,:,2)+hhx.*hhy;
    Clocal(:,:,3)=Clocal(:,:,3)+hhy.^2  ;
    dlocal(:,:,1)=dlocal(:,:,1)+hhx.*ht;
    dlocal(:,:,2)=dlocal(:,:,2)+hhy.*ht;
    
    % optical flow
    [ Ux,Uy ] = obj.fOpticalFlow( h1, h2 );
    U(:,:,1)=U(:,:,1)+Ux;
    U(:,:,2)=U(:,:,2)+Uy;
end

img_ave=img_ave./nke./2;
Uave=U./nke;

if use_gpu
    img_ave=gather(img_ave);
    Uave=gather(Uave);
end

%% LLS
fprintf(1,'\n%s\n','Solve the linear system...');

% local solution
Cdet=Clocal(:,:,1).*Clocal(:,:,3)-Clocal(:,:,2).^2;
tau_local(:,:,1)=-(Clocal(:,:,3).*dlocal(:,:,1)-Clocal(:,:,2).*dlocal(:,:,2))./Cdet;
tau_local(:,:,2)=-(Clocal(:,:,1).*dlocal(:,:,2)-Clocal(:,:,2).*dlocal(:,:,1))./Cdet;
tau_local(isinf(tau_local))=0;
if use_gpu
    tau_local=gather(tau_local);
    Cdet=gather(Cdet);
end

% global solution
CKeep=cell(nW,1);
dKeep=cell(nW,1);
bKeep=cell(nW,1);
tau=cell(nW,1);
for w=1:nW 
    if nW~=1
        fprintf(1,'(%d/%d): ',w,nW);
    end

    C=cC{w};
    d=cd{w};
    A3=cA3{w};
    Bave=cBave{w};
    if use_gpu
        C=gather(C);
        d=gather(d);
        A3=gather(A3);
        Bave=gather(Bave);
    end
    
    if w==1
        spparms('spumoni',1);
    else
        spparms('spumoni',0);
    end
    
    % Modify ROI when ill-posed node is included
    roi_n=roi_node(:,:,w);
%     threshold=eps*2^16;
    threshold=eps*2^2;
    if sum( abs(Cdet(roi_n))<=threshold ) > 0
        fprintf(1,'Modify ROI to avoid ill-posed nodes\n');
        roi_mod=abs(Cdet)>threshold;
        roi_mod=conv2(single(roi_mod),ones(2),'full');
        roi_mod= roi_mod>0 & roi_img(:,:,w);
                
        [ ~,Meffmod,roi_node(:,:,w),roi_tau_x(:,:,w),roi_tau_y(:,:,w),roi_cell(:,:,w)]=...
            obj.fEffMat( Mc2f,SumFlux,Msigma,Diff_x,roi_mod );
        roi_img(:,:,w)=roi_mod;
        
        Mmod=Meffmod*A3;
        C=Mmod*C*Mmod';
        d=Mmod*d;
        A3=Meffmod';
    end
    
    % Solution of LLS
    tau_eff=-(C)\(d);
    
    tau{w}=A3*tau_eff;
    CKeep{w}=C;
    dKeep{w}=d;
    bKeep{w}=Bave./nkw(w);
end
tau=cell2mat(tau');

spparms('spumoni',0);


% save the last image
lastimg=oDataSet.ImgBuffer(:,:,oDataSet.bufferIndex);
if use_gpu==1
    obj.img.ins=gather(lastimg);
else
    obj.img.ins=lastimg;
end

% return results
obj.tau=tau;
obj.tau_local=tau_local;
obj.Uave=Uave;
obj.C=CKeep;
obj.d=dKeep;
obj.bAve=bKeep;
obj.img.ave=img_ave;

obj.roi.img=roi_img;
obj.roi.node=roi_node;
obj.roi.cell=roi_cell;
obj.roi.tau_x=roi_tau_x;           
obj.roi.tau_y=roi_tau_y;

fprintf(1,'%s\n','done');

end

