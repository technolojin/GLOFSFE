function tauVec2Field(obj)
tau=obj.tau;  %#ok<*PROP>
dim=obj.oDataSet.datasize;
ni=dim(1);
nj=dim(2);
roi=obj.oDataSet.getROI();

nW=size(roi,3);

Mtau_x=zeros(ni-1,nj-1,nW);
Mtau_y=zeros(ni-1,nj-1,nW);
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
    f_v2n=[0,1;0,1]/2;
    tau_x=conv2(tau_x,f_v2n ,'valid');
    tau_y=conv2(tau_y,f_v2n','valid');
    
    mask_node=conv2(double(roi(:,:,n)),ones(2),'valid');
    mask_node=mask_node==4;
    Mtau_x(:,:,n)=tau_x.*mask_node;
    Mtau_y(:,:,n)=tau_y.*mask_node;
end
obj.tau_x=Mtau_x;
obj.tau_y=Mtau_y;

end