%% Linear Least-Squares method [step 1]
% The preperation script with detail settings
% All necessary settings are saved as 'dataset' file(s).
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
% Copyright (c) 2019 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php

close all;
clear;

%% inputs

flag_rebuild=1;
% directory
dir_data='../DATA/plate_UWyo/';
dir_case='./case1/';
dir_datasets=[dir_data,'./result/datasets/'];
dir_cases=[dir_data,'./result/cases/'];

dir_cal=struct('dark',[dir_data,dir_case,'./dark/'],...
               'bg',[dir_data,dir_case,'./background/'],...
               'exc',[dir_data,dir_case,'./excitation/'],...
               'scale',[dir_data,dir_case,'./scale/'],...
               'alpha',[dir_data,dir_case,'./alpha/']);

dir_run={[dir_data,'run1','/'];...
         [dir_data,'run2','/'];...
         [dir_data,'run3','/']};

filename_mask=[dir_data,dir_case,'./mask/00001.tif'];

case_name='flat_plate_1';
dataset_names={'case1_all';'case1_1'};

runs2dataset=cell(2,1);
runs2dataset{1}=(1:3);
runs2dataset{2}=1;

% image format
max_image=2^8-1;
img_format='tif';

% calibration parameters
gamma=0.19; %frame rate [frame/second]
visc_oil=0.5295; %oil viscosity [Pa s], 500cSt 20C -> 0.5295
v_oildrop=10e-9;% oil drop volume [liter]

% image process parameters
scale=0.6; % 60%
angle=10; % [deg]

%% set case
filedir=[dir_cases,case_name,'.mat'];
if exist(filedir,'file')~=2
    GLOFcase=cGLOFCase(case_name);
    GLOFcase.setDirCal(dir_cal,img_format,max_image);
    GLOFcase.setFileMask(filename_mask);
    GLOFcase.setScale();     % get scale (pixel per meter)
    GLOFcase.setOilDrops(v_oildrop);  % get alpha (intensity per meter)
    
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
    GLOFcase.setFileMask(filename_mask);
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
    datasets{i}.setCalPara(gamma,visc_oil);
    
end
% save dataset
if ~exist(dir_datasets,'dir')
    mkdir(dir_datasets);
end
for i=1:k
    datasets{i}.save([dir_datasets,datasets{i}.Name,'.mat']);
end

fprintf(1,'done\n');