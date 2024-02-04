function wyb_baricenter_realignment(Project_Path)

% FUNCTION wyb_baricenter_realignment(Project_Path)
% This function will realign the position of each points around the baricenter on the body axis
% stated in wyb_get_baricenter
%
% INPUT:
%   - Project_Path: Path where you want to store results of toolbox
%
%
% Matthieu Aguilera, Funsy Team, Sept 2023

% Load the project_info structure
load([Project_Path,filesep,'Project_info']);

% Find Index of Videos with frames non_extracted
Idx2use = [];
Idx2use = find(Project.Project_List.is_baricenter == 1 & Project.Project_List.is_baricenter_realigned == 0);
Idx2use = Idx2use';

if isempty(Idx2use)
    disp('!!WARNING!!: Either DLC_data baricenters were not computed or points already realigned, please verify the Project_List table')
end

% Set the start of the timer
t_start = []; t_stop = [];
t_start = tic;

% Initialize the progress bar
fprintf('Baricentering progress:   0%%');

% Set imaginary number
i = sqrt(-1);

% Set the index of bodypart used for alignement
Align_Bodypart_Idx = [];
Align_Bodypart_Idx = find(cellfun(@(x) strcmp(x, Project.Body_axis.Align_Bodypart), Project.Bodyparts)==1);

%Loop normalization
for v = Idx2use

    % Load the normalize coordinate table
    Norm_DLC_output = [];
    load([Project.Path.Coordinates,filesep, Project.Project_List.Video_List{v},'.mat']);

    % Translate coordinates to Baricenter referential so baricenter
    % coordinates = (0,0)
    X_value = []; Y_value = [];
    for b = 1:numel(Project.Bodyparts)
        X_value(:,b) = Norm_DLC_output.([Project.Bodyparts{b}, '_x'])-Norm_DLC_output.Baricenter_x;
        Y_value(:,b) = Norm_DLC_output.([Project.Bodyparts{b}, '_y'])-Norm_DLC_output.Baricenter_y;
    end

    % Compute rotation angle of the vector baricenter-Align_Bodypart
    phi = [];
    for t = 1:height(Norm_DLC_output)
        if X_value(t,Align_Bodypart_Idx)>0
            phi(t) =  pi+atan((-Y_value(t,Align_Bodypart_Idx))/(-X_value(t,Align_Bodypart_Idx)));
        else
            phi(t) = atan((-Y_value(t,Align_Bodypart_Idx))/(-X_value(t,Align_Bodypart_Idx)));
        end
    end

    % Align every translated points of each bodyparts by the phi angle
    for b = 1:numel(Project.Bodyparts)
        New_X = nan(height(Norm_DLC_output), 1); New_Y = nan(height(Norm_DLC_output), 1);
        for t = 1:length(X_value)

            imag_coord = [];
            imag_coord = X_value(t,b) + i*Y_value(t,b);

            New_coord = [];
            New_coord = imag_coord*exp(i*((pi/2)-phi(t)));

            New_X(t,1) = real(New_coord);
            New_Y(t,1) = imag(New_coord);


        end
        Norm_DLC_output.(['realigned_',Project.Bodyparts{b},'_x']) = New_X;
        Norm_DLC_output.(['realigned_',Project.Bodyparts{b},'_y']) = New_Y;

    end

    %save the new table
    save([Project.Path.Coordinates, filesep, Project.Project_List.Video_List{v}], 'Norm_DLC_output', '-v7.3');

    writetable(Norm_DLC_output, [Project.Path.Coordinates, filesep, Project.Project_List.Video_List{v},'.csv']);

    % Update project
    Project.Project_List.is_baricenter_realigned(v) = 1;

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