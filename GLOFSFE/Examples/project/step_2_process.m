%% Linear Least-Squares method [step 2]
% The main process script
% The setting files which are saved at step 1 in the indicated directory 
% will be loaded and processed. 
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

clear;
close all;

%% load dataset dirs
dir_data='../DATA/plate_UWyo/';
dir_datasets=[dir_data,'./result/datasets/'];
dir_LLSs=[dir_data,'./result/LLS/'];

File_DATA  = dir(fullfile(dir_datasets,['*.','mat']));  
File_Names = {File_DATA.name};
filedir=cell(size(File_Names,2),1);

f=1:size(File_Names,2);
for i=f
    filedir{i}=[dir_datasets,File_Names{i}];
end

%% parameters
% processing option: 'cpu' or 'gpu'(CUDA)
option='gpu'; 

%% load each dataset and process the LLS method
tic;

if ~exist(dir_LLSs,'dir')
    mkdir(dir_LLSs);
end

LLS=cell(size(File_Names,2),1);
for i=f
    % load a dataset
    dataset=cGLOFDataSet.load(filedir{i});
    
    % LLS
    LLS{i}=cGLOFLLS();
    LLS{i}.runLLS(dataset,option);
    
    % save file
    LLS{i}.save([dir_LLSs,dataset.Name,'_LLS.mat']);
end

fprintf(1,'Execution time:  %s\n',sec2text(toc));

%% plot
close all;

i=1;
[tau_x,tau_y,img]=LLS{i}.getRealTau();% tau [Pa]
plot_tau(tau_x,tau_y,img);

beep;