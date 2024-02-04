function wyb_get_cinetic_per_condition(Project_Path)

% FUNCTION wyb_get_cinetic_per_condition(Project_Path)
% This function will create a table with video title and the different
% conditions previously created in wyb_add_conditions and compute mean
% speeds and accelerations and distance for each video that can be then
% classified by conditions
%
% INPUT:
%   - Project_Path: Path where you want to store results of toolbox
%
% Matthieu Aguilera, Funsy Team, Sept 2023

% Load the project_info structure
load([Project_Path,filesep,'Project_info']);

% Create Conditions Folder Path
if ~isfield(Project.Path, 'Analysis')
    Project.Path.Analysis = [Project_Path, filesep,'Analysis'];
end

% Create Condtions Folder
if ~exist(Project.Path.Analysis)
    mkdir(Project.Path.Analysis);
end

% Set the start of the timer
t_start = []; t_stop = [];
t_start = tic;

% Initialize the progress bar
fprintf('Computing progress:   0%%');

% Load Condition table as base for the results table
Cinetic_per_conditions = readtable([Project.Path.Exp_Info, filesep,'Exp_Info_List.csv'], 'FileType', "text",'Delimiter', ",", 'VariableNamingRule', 'preserve');

% Create variables of results
Mean_speed = nan(height(Cinetic_per_conditions),1);
Mean_angular_speed = nan(height(Cinetic_per_conditions),1);
Distance = nan(height(Cinetic_per_conditions),1);

% Loop for videos
for v = 1:height(Cinetic_per_conditions)

    % Load cinetic from videos
    Video = [];
    Video = Cinetic_per_conditions.Video_List{v};

    Norm_DLC_output = [];
    load([Project.Path.Coordinates,filesep,Video,'.mat']);

    % Compute different variable
    Mean_speed(v,1) = mean(Norm_DLC_output.Baricenter_speed);
    Mean_angular_speed(v,1) = mean(abs(Norm_DLC_output.Baricenter_angular_speed));
    Distance(v,1) = sum(Norm_DLC_output.Baricenter_speed);

     % Calculate the current progress percentage
    progress = [];
    progress = v / height(Cinetic_per_conditions) * 100;

    % Update the progress bar in the command window
    fprintf('\b\b\b\b%3d%%', round(progress));
end

% Add column to cinetic_per_conditions table
Cinetic_per_conditions.Mean_speed = Mean_speed;
Cinetic_per_conditions.Mean_angular_speed = Mean_angular_speed;
Cinetic_per_conditions.Distance = Distance;

% Save table
save([Project.Path.Analysis, filesep, 'Mean_cinetics'], 'Cinetic_per_conditions', '-v7.3');
writetable(Cinetic_per_conditions, [Project.Path.Analysis, filesep,'Cinetic_per_conditions.csv'], 'Delimiter',",");

t_stop = toc(t_start);
disp([' done in ', num2str(t_stop/60), ' min']);

fprintf('\n'); % Print a newline to move to the next line after the loop