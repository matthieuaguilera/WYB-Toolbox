function wyb_normalize_landmark_coord(Project_Path)

% FUNCTION wyb_normalize_landmark_coord(Project_Path)
% This function will normalize the landmark coordinates based on arena
% coordinates
%
% INPUT:
%   - Project_Path: Path where you want to store results of toolbox
%
%
% Matthieu Aguilera, Funsy Team, Sept 2023

% Load the project_info structure
load([Project_Path,filesep,'Project_info']);

% If the function run the first time, add is_landmark_normalized in Project_info
if ~ismember('is_landmark_normalized', Project.Project_List.Properties.VariableNames)
    Project.Project_List.is_landmark_normalized = zeros([length(Project.Project_List.nb_landmark),1]);
end

% Find Index of Videos with frames non_extracted
Idx2use = [];
Idx2use = find(Project.Project_List.is_OF_coord == 1 & Project.Project_List.nb_landmark >0 & Project.Project_List.is_landmark_placed == 1 & Project.Project_List.is_landmark_normalized == 0);
Idx2use = Idx2use';

if isempty(Idx2use)
    disp('!!WARNING!!: Either arena or landmark coordinates not determined or landmark coordinates already normalized for this project dataset, please verify the Project_List table')
end

% Set the start of the timer
t_start = []; t_stop = [];
t_start = tic;

% Initialize the progress bar
fprintf('Normalizing progress:   0%%');

%Loop normalization
for v = Idx2use

    % Load the coordinates from wyb_get_arena_coordinates
    Arena_Coordinates = [];
    load([Project.Path.Arena_Coordinates, filesep, Project.Project_List.Video_List{v}]);

    % Load the coordinates from wyb_add_landmark
    Landmark_Coordinates = [];
    load([Project.Path.Landmark_Coordinates, filesep, Project.Project_List.Video_List{v}]);

    Realign_coord = []; New_origin = [];
    New_origin = Landmark_Coordinates.Coord + Arena_Coordinates.Norm_var.OA_OC;
    Realign_coord = Arena_Coordinates.Norm_var.RM*New_origin;

    Norm_coord = [];

    % Normalize data taking X & Y length in account
    Norm_coord(1,:) = Realign_coord(1,:)./Arena_Coordinates.Norm_var.norm_unit_X;
    Norm_coord(2,:) = Realign_coord(2,:)./Arena_Coordinates.Norm_var.norm_unit_Y;

    Landmark_Coordinates.Norm_coord = Norm_coord;

    % Save coordinates
    save([Project.Path.Landmark_Coordinates,filesep,Project.Project_List.Video_List{v}], 'Landmark_Coordinates', '-v7.3');

    % Update project
    Project.Project_List.is_landmark_normalized(v) = 1;

    % Save Project
    save([Project_Path,filesep,'Project_info'], 'Project', '-v7.3');

    % Calculate the current progress percentage
    progress = [];
    progress = v / max(Idx2use) * 100;

    % Update the progress bar in the command window
    fprintf('\b\b\b\b%3d%%', round(progress));
end

fprintf('\n'); % Print a newline to move to the next line after the loop