function wyb_get_landmark_distance(Project_Path)

% FUNCTION wyb_get_landmark_distance(Project_Path)
% This compute the distance vector between the baricenter of the animal and
% the landmark placed for each videos
%
% INPUT:
%   - Project_Path: Path where you want to store results of toolbox
%
%
% Matthieu Aguilera, Funsy Team, Sept 2023

% Load the project_info structure
load([Project_Path,filesep,'Project_info']);

% If the function run the first time, add is_landmark_normalized in Project_info
if ~ismember('is_landmark_distance', Project.Project_List.Properties.VariableNames)
    Project.Project_List.is_landmark_distance = zeros([length(Project.Project_List.nb_landmark),1]);
end

% Find Index of Videos with frames non_extracted
Idx2use = [];
Idx2use = find(Project.Project_List.nb_landmark >0 & Project.Project_List.is_landmark_normalized == 1 & Project.Project_List.is_landmark_distance == 0);
Idx2use = Idx2use';

if isempty(Idx2use)
    disp('!!WARNING!!: Either arena or landmark coordinates not determined and/or normalized or distance to landmark already computed for this project dataset, please verify the Project_List table')
end

% Set the start of the timer
t_start = []; t_stop = [];
t_start = tic;

% Initialize the progress bar
fprintf('Computing distances progress:   0%%');
%Loop normalization
for v = Idx2use

    % Load the coordinates from wyb_add_landmark
    Landmark_Coordinates = [];
    load([Project.Path.Landmark_Coordinates, filesep, Project.Project_List.Video_List{v}]);

    % Load the normalize coordinate table
    Norm_DLC_output = [];
    load([Project.Path.Coordinates,filesep, Project.Project_List.Video_List{v},'.mat']);

    % Create temporary vector to store the distance
    Distance2Landmark = nan(height(Norm_DLC_output), Project.Project_List.nb_landmark(v));

    % Compute distance between baricenter and landmark as the norm of the
    % vector between the baricenter and the landmark
    for t = 1:height(Norm_DLC_output)
        for land = 1:Project.Project_List.nb_landmark(v)
            Distance2Landmark(t,land) = norm([Norm_DLC_output.Baricenter_x(t) - Landmark_Coordinates.Norm_coord(1,land); Norm_DLC_output.Baricenter_y(t) - Landmark_Coordinates.Norm_coord(2,land)]);
        end
    end

    % Add the distances to the Norm_DLC_output table
    for land = 1:Project.Project_List.nb_landmark(v)
        Norm_DLC_output.(['Distance2Landmark_',num2str(land)]) = Distance2Landmark(:,land);
    end

    % Save the new table in .mat and .csv
    save([Project.Path.Coordinates, filesep, Project.Project_List.Video_List{v}], 'Norm_DLC_output', '-v7.3');

    writetable(Norm_DLC_output, [Project.Path.Coordinates, filesep, Project.Project_List.Video_List{v},'.csv']);

    % Update project
    Project.Project_List.is_landmark_distance(v) = 1;

    % Save Project
    save([Project_Path,filesep,'Project_info'], 'Project', '-v7.3');

    % Calculate the current progress percentage
    progress = [];
    progress = v / max(Idx2use) * 100;

    % Update the progress bar in the command window
    fprintf('\b\b\b\b%3d%%', round(progress));
end

fprintf('\n'); % Print a newline to move to the next line after the loop