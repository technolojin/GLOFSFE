function [ resMeff,Meff,roi_node,roi_vec_x,roi_vec_y,roi_cell] = fEffMat( Mc2f,SumFlux,Msigma,Diff_x,roi_img )

[ni,nj]=size(roi_img);

% effective residual unit
roi_n=abs(SumFlux*Diff_x)*Mc2f*roi_img(:)==4;    

% effective residuals matrix 
nScell=sum(Msigma(1,:),2);
effRes=Msigma*roi_n(:);
effRes=effRes==nScell;

nQ=size(effRes(:),1);
resMeff=spdiags(effRes(:),0,nQ,nQ);

% effective node vector
effNode= Msigma'*effRes > 0;

% effective vector matrix
effVec=abs(Diff_x'*SumFlux')*effNode;
effVec=effVec>0;
if sum(effVec(:))==0
    error('no effective vector');
end

Meff = rdmtx( effVec );

% ROI
roi_node=reshape(full(effNode),ni-1,nj-1);
roi_vec=reshape(full(effVec),ni,nj,2);
roi_vec_x=roi_vec(:,:,1);
roi_vec_y=roi_vec(:,:,2);
roi_cell=(conv2(single(roi_vec_x),[0,1;0,1] ,'valid')==2)&...
         (conv2(single(roi_vec_y),[0,0;1,1] ,'valid')==2); % not related to LLS

end

