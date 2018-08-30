%% Linear Least-Squares method [step 2]
%This is the main process script for GLOF-SFE from setting files which is
%saved at step 1.
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

%% load dataset dirs
clear;

dir_datasets='../../data/plate_UWyo/result/datasets/';
dir_results='../../data/plate_UWyo/result/LLS/';

File_DATA  = dir(fullfile(dir_datasets,['*.','mat']));  
File_Names = {File_DATA.name};

filedir=cell(size(File_Names,2),1);

f=1:size(File_Names,2);

for i=f
    filedir{i}=[dir_datasets,File_Names{i}];
end

%% load each dataset and process the LLS method
tic;
if ~exist(dir_results,'dir')
    mkdir(dir_results);
end

LLSresult=cell(size(File_Names,2),1);
for i=f
    % load a dataset
    dataset=cGLOFDataSet.load(filedir{i});
    
    % LLS
    LLSresult{i}=cGLOFLLS();
    LLSresult{i}=LLSresult{i}.runLLS(dataset,'cpu');% option:'cpu' or 'gpu'(CUDA)
    
    LLSresult{i}.save([dir_results,dataset.Name,'_LLS.mat']);

end
fprintf(1,'Execution time:  %s\n',sec2text(toc));
%% plot
close all;

i=1;
[tau_x,tau_y,img]=LLSresult{i}.getRealTau();% tau [Pa]
plot_tau(tau_x,tau_y,img);

beep;