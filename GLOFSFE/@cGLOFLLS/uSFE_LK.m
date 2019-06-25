function [Tau_x, Tau_y]=uSFE_LK( obj, varargin )
% unsteady skin friction field estimator
% based on Lukas-Kanade method

narginchk(1,2);
use_gpu = ComputingOpt(varargin{:});

%% inputs
oDataSet=obj.oDataSet;

%% dataset
if oDataSet.flagImgLoaded==false
    oDataSet.LoadData();
end

datasize=oDataSet.datasize;
ni=datasize(1);
nj=datasize(2);
nk=datasize(4);

roi=oDataSet.getROI();
%%

C=zeros(ni-1,nj-1,nk,3);
b=zeros(ni-1,nj-1,nk,2);

%% loading images and calculate LLS matrix
fprintf(1,'%s %5.1f%%','Calculate LLS: ',0);
for k=1:nk
    fprintf(1,'\b\b\b\b\b\b');
    fprintf(1,'%5.1f%%',k/nk*100);
    
    [h1,h2]=oDataSet.getPair(k,use_gpu);
    
    
    % local filtering method
    hm=(h1+h2)/2;
    hhm=(hm.^2)/2;
    hhx=conv2(hhm,[1,1;-1,-1]/2,'valid');
    hhy=conv2(hhm,[1,-1;1,-1]/2,'valid');
    ht=conv2(-h1+h2,ones(2)/4,'valid');
    
    C1=hhx.^2  ;
    C2=hhx.*hhy;
    C3=hhy.^2  ;
    b1=hhx.*ht;
    b2=hhy.*ht;

    C1=conv2(C1,ones(5)/25);
    C2=conv2(C2,ones(5)/25);
    C3=conv2(C3,ones(5)/25);
    b1=conv2(b1,ones(5)/25);
    b2=conv2(b2,ones(5)/25);
        
    C(:,:,1)=C1(3:end-2,3:end-2);
    C(:,:,2)=C2(3:end-2,3:end-2);
    C(:,:,3)=C3(3:end-2,3:end-2);
    b(:,:,1)=b1(3:end-2,3:end-2);
    b(:,:,2)=b2(3:end-2,3:end-2);
    
    
end

% local solution
Cdet=C(:,:,1).*C(:,:,3)-C(:,:,2).^2;
tau_local(:,:,1)=-(C(:,:,3).*b(:,:,1)-C(:,:,2).*b(:,:,2))./Cdet;
tau_local(:,:,2)=-(C(:,:,1).*b(:,:,2)-C(:,:,2).*b(:,:,1))./Cdet;
tau_local(isinf(tau_local))=0;
if use_gpu==1
    tau_local=gather(tau_local);
end

Tau_x=tau_local(:,:,1);
Tau_y=tau_local(:,:,2);

end

