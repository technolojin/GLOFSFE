function tauVec2Field(obj)
tau=obj.tau;  %#ok<*PROP>
dim=obj.oDataSet.datasize;
ni=dim(1);
nj=dim(2);
roi_x=obj.roi.tau_x;
roi_y=obj.roi.tau_y;
roi_cell=obj.roi.cell;

nW=size(roi_x,3);
if nW>1
    nW=nW+1;

    roi_xt=sum(roi_x,3);
    roi_yt=sum(roi_y,3);
    tau_t=sum(tau,2)./[roi_xt(:);roi_yt(:)];
    tau_t(isinf(tau_t))=0;
    tau_t(isnan(tau_t))=0;
	tau(:,end+1)=tau_t;
    roi_cell(:,:,end+1)=sum(roi_cell,3);
end

Mtau_x=zeros(ni-1,nj-1,nW);
Mtau_y=zeros(ni-1,nj-1,nW);
f_v2n=[0,1;0,1]/2;
    
for n=1:nW
    % reshape
    tau_temp=reshape(tau(:,n),[ni nj 2]);
    tau_x=tau_temp(:,:,1);
    tau_y=tau_temp(:,:,2);
    
    % remove extreme value
    tau_mag=sqrt(tau_x.^2+tau_y.^2);
    tau_x_med=medfilt2(tau_x,[5, 5]);
    tau_y_med=medfilt2(tau_y,[5, 5]);
    tau_x(tau_mag>50)=tau_x_med(tau_mag>50);
    tau_y(tau_mag>50)=tau_y_med(tau_mag>50);
    
    % vectors to node-center    
    tau_x=conv2(tau_x,f_v2n ,'valid');
    tau_y=conv2(tau_y,f_v2n','valid');

    Mtau_x(:,:,n)=tau_x.*roi_cell(:,:,n);
    Mtau_y(:,:,n)=tau_y.*roi_cell(:,:,n);    
    
    
end
obj.tau_x=single(Mtau_x);
obj.tau_y=single(Mtau_y);

end