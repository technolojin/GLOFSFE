%% Linear Least-Squares method
%This is the main script for GLOF-SFE, without detail settings. 
%It contains basic options such as mask(ROI), re-scaling and rotating the
%given images. Other parameters will be set in default values.
%
%
%See also:
% <a href="https://doi.org/10.1063/1.5001388">Taekjin Lee, Taku Nonomura, 
%   Keisuke Asai, and Tianshu Liu, "Linear least-squares method for global 
%   luminescent oil film skin friction field analysis", Review of 
%   Scientific Instruments 89, 065106 (2018)</a>
% 
% 
% Copyright (c) 2018 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php

%%
close all;
clear;

tic;

%% inputs
% directory
dir_img='../../data/lowAR_Tohoku/Case123/';
dir_mask=[dir_img,'mask/mask.tif'];
% image format
max_image=2^8;
img_format='tif';

scale=1; % image rescaling factor ex) 0.5 : 50% downsampling
angle=0; % [deg] ccw
%% set run images
grun1=cGLOFRun(dir_img,img_format,max_image);
gcase1=cGLOFCase(); 
gcase1.setFileMask(dir_mask);   %option
%% make dataset and rescaling images 
dataset=cGLOFDataSet(gcase1,grun1);
dataset.setRescaleRot(scale,angle);    %option
%% process LLS method
LLS=cGLOFLLS();
LLS=LLS.runLLS(dataset,'cpu');

fprintf(1,'Execution time:  %s\n',sec2text(toc));

%% plot
[tau_x,tau_y,img]=LLS.getTau;
plot_tau(tau_x,tau_y,img);

beep;