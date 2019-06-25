%% Process a project 
% A total project of GLOF-SFE
% 
% This project includes all of detail settings, parameters for
% calibrations, process of the LLS method, analysis of the result, and 
% image noise sensitivity analysis. 
% Each step saves necessary files on the result directory. These scripts 
% can be executed separately. 


%% Step 1: Create setting files
fprintf(1,'\nStep 1: Create setting files\n');
step_1_settings;

%% Step 2: Run the LLS process
fprintf(1,'\nStep 2: Run the LLS process\n');
step_2_process;

%% Step 3: Analyse the results
fprintf(1,'\nStep 3: Analyse the results\n');
step_3_analysis;
