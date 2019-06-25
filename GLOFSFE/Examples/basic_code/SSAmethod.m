%% Snapshot Solution Averaging method
% The main script for GLOF-SFE using the Snapshot-Solution-Averaging
% method 
% The method is developed by Prof. Tianshu Liu, Western Michigan
% University. The main functions are from OpenOpticalFlow, modified by
% Taekjin Lee. 
%
%
% Method, Algorithm: 
%
% * <https://doi.org/10.2514/1.32219 
%    T. Liu, J. Montefort, S. Woodiga, P. Merati, and L. Shen, 
%    "Global Luminescent Oil-Film Skin-Friction Meter", 
%    AIAA Journal, 46:2, 476-485 (2008)>
%
% * <https://doi.org/10.1063/1.5001388 
%    Taekjin Lee, Taku Nonomura, Keisuke Asai, and Tianshu Liu, 
%    "Linear least-squares method for global luminescent oil film skin 
%    friction field analysis", 
%    Review of Scientific Instruments 89, 065106 (2018)>
% 
% 
% 
% Copyright (c) 2018 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php

%% initialization
close all;
clear;
tic;

%% calibration parameters and conditions 
alpha=1; % normalized image intensity per oilthickness [1/meter]
beta=1; % pixel density [pixel/meter]
gamma=1; % time resolution [frame/second]
visc_oil=1; % oil viscosity [Pa*s]

% Lagrange multiplier
lambda1=0.001;
lambda2=0.001;
% iteration number
maxnum1=30;
maxnum2=30;

%% data loading
dir_data='../DATA/';
dir_img=[dir_data,'./lowAR_Tohoku/Case123/'];
dir_mask=[dir_img,'./mask/mask.tif'];
% image format
max_image=2^8-1; % 8 bit image

In=LoadImages(dir_img,'tif')/max_image;
[ni,nj,nk]=size(In);
nk=nk-1;

img=In(:,:,end);

%% boundary conditions
mask=imread(dir_mask)/max_image;

mask_1st=ones(ni,nj);
mask_2nd=mask>0.5;

%% process separation 
% mitigate memory consumption
data_size=ni*nj*nk*2/2^30*115+1.4;% Expected full memory consumption [GB]
n_separation=ceil(data_size/4);% up to 4GB of additional memory is required

nk_sep=floor(nk/n_separation);
nk_rem=mod(nk,n_separation);
if nk_rem==0
    Nk_step=repmat(nk_sep,[n_separation 1]);
else
    Nk_step=[repmat(nk_sep,[n_separation 1]); nk_rem];
end
ns=size(Nk_step,1);
Nr_s=zeros(ns,1);
Nr_e=zeros(ns,1);
for s=1:ns
    Nr_s(s)=sum(Nk_step(1:s-1))+1;
    Nr_e(s)=sum(Nk_step(1:s));
end


%% Horn-Schunck method
ns=size(Nk_step,1);
tau_x=zeros(ni,nj);
tau_y=zeros(ni,nj);
Ux_mean=zeros(ni,nj);
Uy_mean=zeros(ni,nj);

for s=1:ns
    fprintf(1,'%s %i%s%i : ','Part',s,'/',ns);
    nr_s=Nr_s(s);
    nr_e=Nr_e(s);

    [ Ux, Uy, ~] = SSA.horn_schunck(In(:,:,nr_s:nr_e), In(:,:,nr_s+1:nr_e+1),...
        mask_1st, mask_2nd, lambda1, maxnum1);
    
    I=(In(:,:,nr_s:nr_e)+In(:,:,nr_s+1:nr_e+1))/2;
    
    tau_x=tau_x+mean(Ux./I,3)*Nk_step(s)/nk;
    tau_y=tau_y+mean(Uy./I,3)*Nk_step(s)/nk;
    
    Ux_mean=Ux_mean+mean(Ux,3)*Nk_step(s)/nk;
    Uy_mean=Uy_mean+mean(Uy,3)*Nk_step(s)/nk;
    
end

tau_x(isnan(tau_x))=0;
tau_y(isnan(tau_y))=0;
tau_x(isinf(tau_x))=0;
tau_y(isinf(tau_y))=0;

Ux_mean_hs=Ux_mean;
Uy_mean_hs=Uy_mean;
tau_x_hs=tau_x;
tau_y_hs=tau_y;

%% Liu-Shen method (refine)
ns=size(Nk_step,1);
tau_x=zeros(ni,nj);
tau_y=zeros(ni,nj);
Ux_mean=zeros(ni,nj);
Uy_mean=zeros(ni,nj);

for s=1:ns
    fprintf(1,'%s %i%s%i : ','Part',s,'/',ns);
    nr_s=Nr_s(s);
    nr_e=Nr_e(s);
        
    [ Ux, Uy, ~] = SSA.liu_shen(In(:,:,nr_s:nr_e), In(:,:,nr_s+1:nr_e+1),...
        Ux_mean_hs, Uy_mean_hs, mask_1st, mask_2nd, lambda2, maxnum2);
    
    I=(In(:,:,nr_s:nr_e)+In(:,:,nr_s+1:nr_e+1))/2;
    
    tau_x=tau_x+mean(Ux./I,3)*Nk_step(s)/nk;
    tau_y=tau_y+mean(Uy./I,3)*Nk_step(s)/nk;
    
    Ux_mean=Ux_mean+mean(Ux,3)*Nk_step(s)/nk;
    Uy_mean=Uy_mean+mean(Uy,3)*Nk_step(s)/nk;
    
end

tau_x(isnan(tau_x))=0;
tau_y(isnan(tau_y))=0;
tau_x(isinf(tau_x))=0;
tau_y(isinf(tau_y))=0;

% skin friction in real scale [Pa]
realtau_x=tau_x*visc_oil*alpha*gamma/beta;
realtau_y=tau_y*visc_oil*alpha*gamma/beta;

fprintf(1,'Execution time:  %s\n',sec2text(toc));

%% plot
plot_tau(tau_x,tau_y,img);

beep;