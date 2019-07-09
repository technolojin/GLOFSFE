function sens_analy = SensAnaly(obj,n,use_gpu)
% image noise sensitivity analysis
%
%SYNOPSIS:
% [ s ] = SensAnaly( oGLOFLLS, n, C)
%
%INPUT:
%   oGLOFLLS: cGLOFLLS object
%   n: ROI number
%   option: (opt) set 'gpu' if want to use 'Parallel Computing Toolbox'
%
%OUTPUT:
%   sens_analy: image noise sensitivity field
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
% Copyright (c) 2019 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php


%%
roi=obj.roi.img;
oDataSet=obj.oDataSet;
tau=obj.tau(:,n); 
roi=roi(:,:,n); 
C=obj.C{n};

Scell=ones(1);

%% dataset
if oDataSet.flagImgLoaded==false
    oDataSet.LoadData();
end

datasize=oDataSet.datasize;
ni=datasize(1);
nj=datasize(2);
nk=datasize(4);

%% scheme and initial matrixes

[ Mave,Mc2f,SumFlux,Msigma,Diff_x,Diff_t ]=obj.fScheme( ni,nj,Scell );
[ resMeff,Meff,~,~,~,~ ] = obj.fEffMat( Mc2f,SumFlux,Msigma,Diff_x,roi );

A1=resMeff*Msigma*SumFlux*Diff_x;
A2=Mc2f*Mave;
A3=Meff';
B1=resMeff*Msigma*Diff_t;

clear('Mave','Mc2f','resMeff','SumFlux','Msigma',...
        'Diff_x','Diff_t','Meff');

%% Image noise sensitivity analysis
nF=size(A2,1);
nNeff=size(A3,2);

fprintf(1,'calculate inverse matrix...\n');
M1=full(inv(C));
fprintf(1,'done\n');

A3T=A3';
M2=A1'*A1;
M3=A1'*B1;
m4=tau(:);
sens_analy=zeros(nNeff,1);

fprintf(1,'Image noise sensitivity analysis ready\n');
%% loading images and calculate image noise sensitivity
fprintf(1,'%s %05.1f%%','Calculate noise sensitivity : ',0);
for k=1:nk
    fprintf(1,'\b\b\b\b\b\b');
    fprintf(1,'%05.1f%%',k/nk*100);
    
    [h1,h2]=oDataSet.getPair(k,use_gpu);
    if use_gpu==1
        h1=gather(h1);
        h2=gather(h2);
    end
    
    h=[h1(:);h2(:)];
    
    m5=A2*h;
    M6=sparse(1:nF,1:nF,m5.^2,nF,nF);

    % accumulate sensitivity square
    G=-1/2*((sparse(1:nF,1:nF,m5.*(M2*(M6*m4)),nF,nF)...
        +M6*(M2*sparse(1:nF,1:nF,m5.*m4,nF,nF))...
        +2*sparse(1:nF,1:nF,m5.*(M3*h),nF,nF))*A2...
        +M6*M3);
    
    Ap=M1*(A3T*G*A3);
    sens_analy=sens_analy+(Ap.^2)*ones(nNeff,1);
end

sens_analy=A3*sens_analy;
sens_analy=reshape(sens_analy.^0.5,ni,nj,2);
            
fprintf(1,'   done \n');

end

