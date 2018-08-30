%% Linear Least-Squares method [step 1]
%This is the preperation script for GLOF-SFE, with detail settings. 
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

%% inputs
flag_rebuild=1;
% directory
dir_imgdata='../../data/plate_UWyo/case1/';

dir_datasets='../../data/plate_UWyo/result/datasets/';
dir_cases='../../data/plate_UWyo/result/cases/';

dir_cal={[dir_imgdata,'dark','/'];...
    [dir_imgdata,'background','/'];...
    [dir_imgdata,'excitation','/'];...
    [dir_imgdata,'scale','/'];...
    [dir_imgdata,'alpha','/']};% dark bg exc scale alpha

dir_run={[dir_imgdata,'run1','/'];...
    [dir_imgdata,'run2','/'];...
    [dir_imgdata,'run3','/'];...
    [dir_imgdata,'run4','/'];...
    [dir_imgdata,'run5','/']};

dir_mask=[dir_imgdata,'mask/00001.tif'];

case_name='flat_plate_1';

dataset_names={'case1_all';'case1_1'};

runs2dataset=cell(2,1);
runs2dataset{1}=(1:5);
runs2dataset{2}=1;

% image format
max_image=2^14;
img_format='tif';
% parameters
gamma=0.19; %frame rate [frame/second]
visc_oil=0.5295; %oil viscosity [Pa s], 500cSt 20C -> 0.5295

scale=0.6; % 60%
angle=0; % [deg]

%% set case
filedir=[dir_cases,case_name,'.mat'];
if exist(filedir,'file')~=2
    GLOFcase=cGLOFCase(case_name);
    GLOFcase.setDirCal(dir_cal,img_format,max_image);
    GLOFcase.setFileMask(dir_mask);
    GLOFcase.setScale();     % get scale (pixel per meter)
    GLOFcase.setOilDrops();  % get alpha (intensity per meter)
    
    if ~exist(dir_cases,'dir')
        mkdir(dir_cases);
    end
    GLOFcase.save(filedir);
else
    GLOFcase=cGLOFCase.load(filedir);
end
% rebuild case file
if flag_rebuild
    GLOFcase=cGLOFCase.load(filedir);
    GLOFcase.setDirCal(dir_cal,img_format,max_image);
    GLOFcase.setFileMask(dir_mask);
    GLOFcase.save(filedir);    
end
%% set run images
Runs=cell(max(size(dir_run)),1);
for k=1:max(size(dir_run))
    Runs{k}=cGLOFRun(dir_run{k},img_format,max_image);
end

%% make dataset and rescaling images
k=max(size(runs2dataset));
datasets=cell(k,1);

for i=1:k
    j=runs2dataset{i};
    datasets{i}=cGLOFDataSet(GLOFcase,Runs(j),dataset_names{i});
   
    % setting median filter on excitation map image
    n_med=20;
    datasets{i}.setMedianCalImages(n_med,{'exc'});
    % setting rescaling parameters
    datasets{i}.setRescaleRot(scale,angle);
    % setting calibration parameters
    datasets{i}.flagCalPara=true;
    datasets{i}.CalPara.gamma=gamma;
    datasets{i}.CalPara.visc_oil=visc_oil;
    
end
% save dataset
if ~exist(dir_datasets,'dir')
    mkdir(dir_datasets);
end
for i=1:k
    datasets{i}.save([dir_datasets,datasets{i}.Name,'.mat']);
end
