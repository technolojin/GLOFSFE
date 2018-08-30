function [ Ux, Uy, error ] = horn_schunck( In1, In2, mask_1st, mask_2nd,...
    lambda, maxnum)
%HORN_SCHUNCK horn-schunck optical flow estimator
% 
% INPUT:
%   In1, In2: image matrix 
%   mask_1st: matrix for Dirichlet(first-type) boundary condition
%   mask_2nd: matrix for Neumann (second-type) boundary condition
%   lambda: regularization parameter
%   maxnum: iteration number
%
% OUTPUT:
%   Ux, Uy: estimated optical flow
%
%
%See also:
% <a href="https://github.com/Tianshu-Liu/OpenOpticalFlow">
%  OpenOpticalFlow</a>
% <a href="http://doi.org/10.5334/jors.168"> Tianshu Liu, "OpenOpticalFlow:
%  An Open Source Program for Extraction of Velocity Fields from Flow 
%  Visualization Images"</a>
%
%
% Original work Copyright (c) 2017 Tianshu Liu
% Released under the MIT license
%
% Copyright (c) 2018 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php

%%
H = [1, 1, 1; 1,0,1;1,1,1]; 
D = [0, -1, 0; 0,0,0; 0,1,0]/2; %%% partial derivative 
[ni,nj,nk]=size(In1);

%% boundary conditions
% 2nd
cmtx =imfilter(uint8(mask_2nd), H, 'same',0);
bound_a=logical((0<cmtx).*(cmtx<8));
cmtx(cmtx==0)=1;

% 1st
D_ex= [-1, -1, -1; 0,0,0;1,1,1]; 
Me= [1,1,1;1,1,1;1,1,1]/9; 

norm_inner_x=imfilter(double(mask_1st), D_ex, 'same',1);
norm_inner_y=imfilter(double(mask_1st), D_ex', 'same',1);
norm_inner_x=imfilter(norm_inner_x, Me, 'same',1);
norm_inner_y=imfilter(norm_inner_y, Me, 'same',1);
norm=((norm_inner_x.^2+norm_inner_y.^2).^(0.5));
norm(norm==0)=1;
norm_inner_x=norm_inner_x./norm;
norm_inner_y=norm_inner_y./norm;

cmtx_in =imfilter(uint8(mask_1st), H, 'same',1);
bound_b=(0<cmtx_in).*(cmtx_in<8);
bound_b=logical(bound_b.*mask_2nd);

%% image process
I=(In1+In2)/2;
Ix=imfilter(I, D, 'replicate',  'same');
Iy=imfilter(I, D', 'replicate',  'same');
It=In2-In1;

Ux=zeros(size(In1));
Uy=zeros(size(In1));

denomi=lambda*ones(size(I))+Ix.^2+Iy.^2;

%% initialization
cmtx_k=repmat(cmtx,[1 1 nk]);
bound_a_k=repmat(bound_a,[1 1 nk]);
bound_b_k=repmat(bound_b,[1 1 nk]);
mask_2nd_k=logical(repmat(mask_2nd,[1 1 nk]));
mask_1st_k=logical(repmat(mask_1st,[1 1 nk]));
norm_1st_x_k=repmat(norm_inner_x,[1 1 nk]);
norm_1st_y_k=repmat(norm_inner_y,[1 1 nk]);
error=zeros(maxnum,1);

%%
k=0;
fprintf(1,'%s %5.1f%%','run Horn-Schunck method : ',0);
while k < maxnum
    k=k+1;

    Ux_bar=imfilter(Ux, H, 'same')./double(cmtx_k);
    Uy_bar=imfilter(Uy, H, 'same')./double(cmtx_k);
    
    Uxnew = Ux_bar-Ix.*(Ix.*Ux_bar+Iy.*Uy_bar+It)./denomi;
    Uynew = Uy_bar-Iy.*(Ix.*Ux_bar+Iy.*Uy_bar+It)./denomi;
    
    %overwrite boundary conditions into optical flow vectors
    norm=Uxnew.*norm_1st_x_k+Uynew.*norm_1st_y_k;
    Ux_surf=Uxnew-norm.*norm_1st_x_k;
    Uy_surf=Uynew-norm.*norm_1st_y_k;  
    
    Uxnew(bound_a_k)=Ux_bar(bound_a_k);
    Uynew(bound_a_k)=Uy_bar(bound_a_k);
    
    Uxnew(bound_b_k)=Ux_surf(bound_b_k);
    Uynew(bound_b_k)=Uy_surf(bound_b_k); 
    Uxnew=Uxnew.*mask_2nd_k.*mask_1st_k;
    Uynew=Uynew.*mask_2nd_k.*mask_1st_k; 
    
    total_error = (sum(sum(sum((Uxnew-Ux).^2+(Uynew-Uy).^2)))).^(1/2)/(ni*nj);
    error(k)=total_error;
        
    Ux = Uxnew;
    Uy = Uynew;
    
    fprintf(1,'\b\b\b\b\b\b');
    fprintf(1,'%5.1f%%',k/maxnum*100);
end

fprintf(1,' %s\n','done');

end

