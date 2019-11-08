function SensStat( obj, use_gpu )
% Image noise sensitivity analysis by the Monte Carlo method
% Add arbitrary image noise and measure variance of estimated tau

nSample=obj.sens_stat.nSample;
sigma=obj.sens_stat.sigma;
if sigma==0
   error('invalid image noise range'); 
else
    sigma=abs(sigma);
end

if nSample==0
   error('invalid sampling number'); 
end

Scell=ones(1);

%% dataset
oDataSet=obj.oDataSet;
if oDataSet.flagImgLoaded==false
    oDataSet.LoadData();
end

datasize=oDataSet.datasize;
ni=datasize(1);
nj=datasize(2);
nk=datasize(4);

roi=obj.roi.img;

%% scheme and initial matrixes
% multiple roi (in 3rd dim)
nW=size(roi,3);
cA1=cell(nW,1);
cA3=cell(nW,1);
cA1T=cell(nW,1);
cA3T=cell(nW,1);
cB1=cell(nW,1);

cC=cell(nW,nSample);
cd=cell(nW,nSample);

% scheme matrix
[ Mave,Mc2f,SumFlux,Msigma,Diff_x,Diff_t ]=obj.fScheme( ni,nj,Scell );

for w=1:nW

    [ resMeff,Meff,~,~,~,~ ] = obj.fEffMat( Mc2f,SumFlux,Msigma,Diff_x,roi(:,:,w)  );
    
    A1=resMeff*Msigma*SumFlux*Diff_x;
    A2=Mc2f*Mave;
    A3=Meff';
    B1=resMeff*Msigma*Diff_t;
    
    % initialization
    nNeff=size(A3,2);
    nF=size(A2,1);
    
    C=sparse(1,1,0,nNeff,nNeff);
    d=zeros(nNeff,1);

    % send to gpu memory
    if use_gpu==1
        A1=gpuArray(A1);
        A3=gpuArray(A3);
        B1=gpuArray(B1);
        C=gpuArray(C);
        d=gpuArray(d);
    end
    % contain in cells
    cA1{w}=A1;
    cA3{w}=A3;
    cA1T{w}=A1';
    cA3T{w}=A3';
    cB1{w}=B1;
    for n=1:nSample
        cC{w,n}=C;
        cd{w,n}=d;
    end
    
    clear('A1','A3','B1','C','d');
    
end

% send to gpu memory
if use_gpu==1
    A2=gpuArray(A2);
end

%% loading images and calculate image noise sensitivity
fprintf(1,'%s %5.1f%%','Calculate image noise sensitivity: ',0);
for k=1:nk
    fprintf(1,'\b\b\b\b\b\b');
    fprintf(1,'%5.1f%%',k/nk*100);
    
    [h1,h2]=oDataSet.getPair(k,use_gpu);
    h=[h1(:);h2(:)];
    
    % repeat to add error 
    for n=1:nSample
        if use_gpu==1
            he=h+randn([nF,1],'gpuArray').*sigma;
        else
            he=h+randn([nF,1]).*sigma;
        end
        
        hf=A2*he;
        hh=sparse(1:nF,1:nF,hf.*hf/2,nF,nF);
    
        % on each roi
        for w=1:nW
            Ak=cA1{w}*hh*cA3{w};
            AkT=cA3T{w}*hh*cA1T{w};
            Bk=cB1{w}*he;
            
            % accumulate LLS matrix
            cC{w,n}=cC{w,n}+AkT*Ak;
            cd{w,n}=cd{w,n}+AkT*Bk;
        end
    end
end

%% LLS
fprintf(1,'\n%s\n','Solve equations...');
tau=cell(nW,nSample);
for w=1:nW
    for n=1:nSample
        C=cC{w,n};
        d=cd{w,n};
        A3=cA3{w};
        
        if use_gpu==1
            C=gather(C);
            d=gather(d);
            A3=gather(A3);
        end
        if w==1&&n==1
            spparms('spumoni',1);
        else
            spparms('spumoni',0);
        end
        
        %C(end,end-1)=1E-20; % force to select UMFPACK solver
        tau_eff=-(C)\(d);
        tau{w,n}=A3*tau_eff;
    end
end
spparms('spumoni',0);

%% analysis results
tau_ave=cell(nW,1);
tau_var=cell(nW,1);
tau_skew=cell(nW,1);
sens_stat=cell(nW,1);
for w=1:nW
    tau_esti=obj.tau(:,w);
    tau_ave{w}=zeros(nF,1);
    tau_var{w}=zeros(nF,1);
    tau_skew{w}=zeros(nF,1);
    
    for n=1:nSample
        tau_ave{w}=tau_ave{w}+tau{w,n};
    end
    tau_ave{w}=tau_ave{w}./(nSample);
    
    for n=1:nSample
        tau_var{w}=tau_var{w}+(tau_esti-tau{w,n}).^2;
        tau_skew{w}=tau_skew{w}+(tau_esti-tau{w,n}).^3;
    end
    tau_var{w}=tau_var{w}./(nSample); % tau variance
    tau_skew{w}=tau_skew{w}./(nSample).*(tau_var{w}.^(3/2));
    
    sens_stat{w}=((tau_var{w}).^0.5)./(abs(sigma));
    sens_stat{w}=reshape(sens_stat{w},ni,nj,2);
    
    tau_ave{w}=single(tau_ave{w});
    tau_var{w}=single(tau_var{w});
    tau_skew{w}=single(tau_skew{w});
    sens_stat{w}=single(sens_stat{w});
end

%% 
obj.sens_stat.sens=sens_stat;
obj.sens_stat.ave=tau_ave;
obj.sens_stat.var=tau_var;
obj.sens_stat.skew=tau_skew;

fprintf(1,'%s\n','done');

end

