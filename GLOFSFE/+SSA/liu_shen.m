function [ Ux, Uy, error ] = liu_shen( In1, In2, Ux_mean, Uy_mean,...
    mask_1st, mask_2nd, lambda, maxnum )
%LIU_SHEN liu-shen optical flow estimator
%
%INPUT:
%   In1, In2: image matrix 
%   Ux_mean, Uy_mean: initial optical flow (obtained from horn-shunck method)
%   mask_1st: matrix for Dirichlet(first-type) boundary condition
%   mask_2nd: matrix for Neumann (second-type) boundary condition
%   lambda: regularization parameter
%   maxnum: iteration number
% 
%OUTPUT:
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
% Original work:
% Copyright (c) 2017 Tianshu Liu
% Released under the MIT license
%
% Modified:
% Copyright (c) 2018 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php

%%
D = [0, -1, 0; 0,0,0; 0,1,0]/2; % partial derivative 
D2 =  [0, 1, 0; 0,-2,0;0,1,0];  % partial derivative
M = [1, 0, -1; 0,0,0;-1,0,1]/4; % mixed partial derivatives
F = [0, 1, 0; 0,0,0;0,1,0];     % average
H = [1, 1, 1; 1,0,1;1,1,1]; 

[nj,ni,nk]=size(In1);

%% boundary conditions
% 2nd
cmtx =imfilter(uint8(mask_2nd), H, 'same',0);
bound_a=logical((0<cmtx).*(cmtx<8));
cmtx(cmtx==0)=1;
cmtx_k=repmat(cmtx,[1 1 nk]);

% 1st
D_ex= [-1, -1, -1; 0,0,0;1,1,1]; 
Me= [1,1,1;1,1,1;1,1,1]/9; 

norm_1st_x=imfilter(double(mask_1st), D_ex, 'same',1);
norm_1st_y=imfilter(double(mask_1st), D_ex', 'same',1);
norm_1st_x=imfilter(norm_1st_x, Me, 'same',1);
norm_1st_y=imfilter(norm_1st_y, Me, 'same',1);
norm=((norm_1st_x.^2+norm_1st_y.^2).^(0.5));
norm(norm==0)=1;
norm_1st_x=norm_1st_x./norm;
norm_1st_y=norm_1st_y./norm;

cmtx_in =imfilter(uint8(mask_1st), H, 'same',1);
bound_b=(0<cmtx_in).*(cmtx_in<8);
bound_b=logical(bound_b.*mask_2nd);

%% image process
I=(In1+In2)/2;
Ix=imfilter(I, D, 'replicate',  'same');
Iy=imfilter(I, D', 'replicate',  'same');
It=(In2-In1);

IIx = I.*Ix;
IIy = I.*Iy;
II = I.*I;
Ixt = I.*imfilter(It, D, 'replicate',  'same');
Iyt = I.*imfilter(It, D', 'replicate',  'same');

clear Ix Iy;

cmtx = imfilter(ones(size(I)), H, 'same');

A11 = I.*(imfilter(I, D2, 'replicate',  'same')-2*I) - lambda*cmtx; 
A22 = I.*(imfilter(I, D2', 'replicate',  'same')-2*I) - lambda*cmtx; 
A12 = I.*imfilter(I, M, 'replicate',  'same'); 
    
DetA = A11.*A22-A12.*A12;

B11 = A22./DetA;
B12 = -A12./DetA;
B22 = A11./DetA;

clear A11 A12 A22 DetA cmtx;

%% initialization
Ux=repmat(Ux_mean,[1 1 nk]);
Uy=repmat(Uy_mean,[1 1 nk]);

bound_a_k=repmat(bound_a,[1 1 nk]);
bound_b_k=repmat(bound_b,[1 1 nk]);
mask_2nd_k=logical(repmat(mask_2nd,[1 1 nk]));
mask_1st_k=logical(repmat(mask_1st,[1 1 nk]));
norm_1st_x_k=repmat(norm_1st_x,[1 1 nk]);
norm_1st_y_k=repmat(norm_1st_y,[1 1 nk]);

%% iteration
k=0;
error=zeros(maxnum,1);
fprintf(1,'%s %5.1f%%','run Liu-Shen method (refine): ',0);
while k < maxnum
    k=k+1;
    
    bux = 2*IIx.*imfilter(Ux, D, 'replicate',  'same')+ ... 
        IIx.*imfilter(Uy, D', 'replicate',  'same')+ ...
        IIy.*imfilter(Uy, D, 'replicate',  'same') + ... 
        II.*imfilter(Ux, F, 'replicate',  'same')+ ... 
        II.*imfilter(Uy, M, 'replicate',  'same') + ... 
        lambda*imfilter(Ux, H, 'same')+Ixt;
    
    buy = IIy.*imfilter(Ux, D, 'replicate',  'same') + ...
         IIx.*imfilter(Ux, D', 'replicate',  'same') + ...
         2*IIy.*imfilter(Uy, D', 'replicate',  'same')+ ...
         II.*imfilter(Ux, M, 'replicate',  'same') + ...
         II.*imfilter(Uy, F', 'replicate',  'same')+ ... 
         lambda*imfilter(Uy, H, 'same')+Iyt;
     
    Uxnew = -(B11.*bux+B12.*buy);
    Uynew = -(B12.*bux+B22.*buy);

    
    %overwrite boundary conditions into optical flow vectors  
    Ux_bar=imfilter(Uxnew, H, 'same')./double(cmtx_k);
    Uy_bar=imfilter(Uynew, H, 'same')./double(cmtx_k);
    
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

