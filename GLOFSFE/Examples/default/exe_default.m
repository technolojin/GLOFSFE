%% Linear Least-Squares method
% This is the main script for GLOF-SFE, without detail settings. 
% All necessary parameters will be set in default values.
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
% image format
img_format='tif';

%% make a dataset 
dataset=cGLOFDataSet( cGLOFCase(),cGLOFRun(dir_img,img_format) );

%% process LLS method
LLS=cGLOFLLS();
LLS.runLLS(dataset);

fprintf(1,'Execution time:  %s\n',sec2text(toc));

%% plot
[tau_x,tau_y,img]=LLS.getTau;
plot_tau(tau_x,tau_y,img);

beep;