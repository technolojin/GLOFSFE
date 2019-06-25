%% Linear Least-Squares method [step 3]
% This is additional analysis process script from LLS files which are
% saved at step 2.
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

%% load dataset dirs
dir_data='../DATA/plate_UWyo/';
dir_LLSs=[dir_data,'./result/LLS/'];

File_DATA  = dir(fullfile(dir_LLSs,['*.','mat']));  
File_Names = {File_DATA.name};
n_sets=size(File_Names(:),1);

f=1:n_sets;

%% parameters
% processing option: 'cpu' or 'gpu'(CUDA)
option='gpu'; 

% image noise sensitivity analysis
sigma=0.001;
nSample=20;

%% load each dataset and process the LLS method
tic;

LLS=cell(size(File_Names,2),1);
for i=f   
    % load file
    filename=[dir_LLSs,File_Names{i}];
    LLS{i}=cGLOFLLS.load(filename);
    
    % run Coefficient of determination analysis
    LLS{i}.runAnalysis(option);
    % run Uncertainty analysis (Monte Carlo method)
    LLS{i}.runSensStat(sigma,nSample,option);
%     % run Uncertainty analysis (Analytical method)
%     LLS{i}.runSensAnaly(option);
    
    % save
    LLS{i}.save(filename);
end

fprintf(1,'Execution time:  %s\n',sec2text(toc));


beep;