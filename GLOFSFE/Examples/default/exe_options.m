%% Linear Least-Squares method
% This is the main script for GLOF-SFE, without detail settings. 
% It contains basic options such as mask, re-scaling and rotating the
% given images. Other parameters will be set in default values.
%
%
% Method, Algorithm: 
%
% * <https://doi.org/10.1063/1.5001388 
%    Taekjin Lee, Taku Nonomura, Keisuke Asai, and Tianshu Liu, 
%    "Linear least-squares method for global luminescent oil film skin 
%    friction field analysis", 
%    Review of Scientific Instruments 89, 065106 (2018)>
% 
% 
% Copyright (c) 2018 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php

%% initialization
close all;
clear;
tic;

%% inputs

% directory
dir_data='../DATA/';
dir_img=[dir_data,'./lowAR_Tohoku/Case123/'];
filename_mask=[dir_img,'./mask/mask.tif'];

% image format
max_image=2^8-1;
img_format='tif';

scale=0.5; % image rescaling factor ex) 0.5 : 50% downsampling
angle=10; % [deg] ccw

% select computing option: 'cpu' or 'gpu'(CUDA)
option='cpu'; 

% names
case_name='Case1';
dataset_name='Dataset1';

%% set run images
grun1=cGLOFRun(dir_img,img_format,max_image);
gcase1=cGLOFCase(case_name); 
gcase1.setFileMask(filename_mask);   

%% make dataset and rescaling images 
dataset=cGLOFDataSet(gcase1,grun1,dataset_name);
dataset.setRescaleRot(scale,angle);    

%% process LLS method
LLS=cGLOFLLS();
LLS.runLLS(dataset,option);

fprintf(1,'Execution time:  %s\n',sec2text(toc));

%% plot
[tau_x,tau_y,img]=LLS.getTau;
plot_tau(tau_x,tau_y,img);

beep;