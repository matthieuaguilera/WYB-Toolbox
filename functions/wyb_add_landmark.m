function wyb_add_landmark(Project_Path)

% FUNCTION wyb_add_landmark(Project_Path)
% This function will allow to get landmarks coordinates
%
% INPUT:
%   - Project_Path: Path where you want to store results of toolbox
%
%
% Matthieu Aguilera, Funsy Team, Sept 2023

% Load the project_info structure
load([Project_Path,filesep,'Project_info']);

% If the function run the first time, add object conditions in Project_info
if ~ismember('nb_landmark', Project.Project_List.Properties.VariableNames)
    Info_table = readtable([Project.Path.Exp_Info, filesep,'Exp_Info_List.csv'], 'FileType', "text",'Delimiter', ",", 'VariableNamingRule', 'preserve');
    Project.Project_List.nb_landmark = Info_table.nb_landmark;
    Project.Project_List.is_landmark_placed = zeros([length(Project.Project_List.nb_landmark),1]);
end

% Find Index of Videos with frames non_extracted
Idx2use = [];
Idx2use = find(Project.Project_List.is_frame ==1 & Project.Project_List.nb_landmark >0 & Project.Project_List.is_landmark_placed == 0);
Idx2use = Idx2use';

if isempty(Idx2use)
    disp('!!WARNING!!: Either frames were not extracted, nb of landmark not determined or landmark already placed for this project dataset, please verify the Project_List table')
end

% Loop frames coordinates
disp('Frame of the video will appear, landmark need to be coded in the same way for every videos, e.g. for an object task, the different objects need to be clicked in the same order')
disp('Coordinates and project are updated and saved at each iteration, you can stop the function by typing Ctrl+C, when you will rerun the function it will restart where you stopped')

if ~isfield(Project.Path,'Landmark_Coordinates')
    Project.Path.Landmark_Coordinates = [Project_Path,filesep,'Landmark_Coordinnates'];
    mkdir(Project.Path.Landmark_Coordinates);
end

% Initialize the progress bar
fprintf('Indexing progress:   0%%');
for v = Idx2use
    IMG = [];
    IMG = imread([Project.Path.Frames,filesep,Project.Project_List.Video_List{v},'.jpg']);
    fig1 = figure('WindowState','fullscreen');
    imshow(IMG);

    x_landmark = []; y_landmark = [];
    [x_landmark, y_landmark] = wyb_ginput(Project.Project_List.nb_landmark(v));

    close(fig1);

    Landmark_Coordinates.Coord(1,:) = x_landmark;
    Landmark_Coordinates.Coord(2,:) = y_landmark;

    Landmark_Coordinates.Landmark_Idx = [];
    for l = 1:Project.Project_List.nb_landmark(v)
        Landmark_Coordinates.Landmark_Idx = {Landmark_Coordinates.Landmark_Idx, ['Landmark_',num2str(l)]};
    end

    % Save coordinates
    save([Project.Path.Landmark_Coordinates,filesep,Project.Project_List.Video_List{v}], 'Landmark_Coordinates', '-v7.3');

    % Update project
    Project.Project_List.is_landmark_placed(v) = 1;

    % Save Project
    save([Project_Path,filesep,'Project_info'], 'Project', '-v7.3');
    
    % Calculate the current progress percentage
    progress = [];
    progress = v / max(Idx2use) * 100;

    % Update the progress bar in the command window
    fprintf('\b\b\b\b%3d%%', round(progress));
end

fprintf('\n'); % Print a newline to move to the next line after the loop