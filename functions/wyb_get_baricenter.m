function wyb_get_baricenter(Project_Path, Center_Bodypart, Align_Bodypart)

% FUNCTION wyb_get_baricenter(Project_Path)
% This function will compute the baricenter coordinates of each frames
% which is the mean of the Center_Bodypart-Align_Bodypart vector, this will be added
% to the normailzed data table
%
% INPUT:
%   - Project_Path: Path where you want to store results of toolbox
%   - Center_Bodypart: name in char of the central bodypart of the skeleton e.g
%                      'Body'
%   - Align_Bodypart: name in char of the bodypart of the skeleton that will set the reference 
%                     axis with the central one e.g 'Neck'
%
%
% Matthieu Aguilera, Funsy Team, Sept 2023

% Load the project_info structure
load([Project_Path,filesep,'Project_info']);

% Add Center_Bodypart and Align_Bodypart to the project structure
Project.Body_axis.Center_Bodypart = Center_Bodypart;
Project.Body_axis.Align_Bodypart = Align_Bodypart;
Project.Body_axis.Bodypart_axis = {Center_Bodypart, Align_Bodypart};

% Find Index of Videos with frames non_extracted
Idx2use = [];
Idx2use = find(Project.Project_List.is_norm == 1 & Project.Project_List.is_baricenter == 0);
Idx2use = Idx2use';

if isempty(Idx2use)
    disp('!!WARNING!!: Either DLC_data were not normalized for this project dataset or baricenters already computed, please verify the Project_List table')
end

% Set the start of the timer
t_start = []; t_stop = [];
t_start = tic;

% Initialize the progress bar
fprintf('Baricentering progress:   0%%');
%Loop normalization
for v = Idx2use

    % Load the normalize coordinate table
    Norm_DLC_output = [];
    load([Project.Path.Coordinates,filesep, Project.Project_List.Video_List{v},'.mat']);

    % Create a Matrix of x coordinates and one of y coordinates
    X_Coord = []; Y_Coord = []; Likelihood = [];

    for b = 1:numel(Project.Body_axis.Bodypart_axis)
        X_Coord(:,b) = Norm_DLC_output.([Project.Body_axis.Bodypart_axis{b},'_x']);
        Y_Coord(:,b) = Norm_DLC_output.([Project.Body_axis.Bodypart_axis{b},'_y']);
        Likelihood(:,b) = Norm_DLC_output.([Project.Body_axis.Bodypart_axis{b},'_likelihood']);
    end

    % Create baricenters which are the mean of the previously done matrices
    Baricenter_x = []; Baricenter_y = []; Baricenter_likelihood = [];
    Baricenter_x = mean(X_Coord,2);
    Baricenter_y = mean(Y_Coord,2);
    Baricenter_likelihood = mean(Likelihood, 2);

    % Add the baricenter variables
    Norm_DLC_output = addvars(Norm_DLC_output, Baricenter_x, Baricenter_y, Baricenter_likelihood);

    %save the new table
    save([Project.Path.Coordinates, filesep, Project.Project_List.Video_List{v}], 'Norm_DLC_output', '-v7.3');

    writetable(Norm_DLC_output, [Project.Path.Coordinates, filesep, Project.Project_List.Video_List{v},'.csv']);

    % Update project
    Project.Project_List.is_baricenter(v) = 1;

    % Save Updated project
    save([Project_Path,filesep,'Project_info'], 'Project', '-v7.3');

    % Calculate the current progress percentage
    progress = [];
    progress = v / numel(Idx2use) * 100;

    % Update the progress bar in the command window
    fprintf('\b\b\b\b%3d%%', round(progress));
end

t_stop = toc(t_start);
disp([' done in ', num2str(t_stop/60), ' min']);

fprintf('\n'); % Print a newline to move to the next line after the loop