function wyb_get_cinetic(Project_Path)

% FUNCTION wyb_get_cinetic(Project_Path)
% This function will compute the speed (norm of the vector between position at time t and time t-1), acceleration (2nd derivative) and
% jerk (3rd derivative) of the baricenter positions
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
Idx2use = find(Project.Project_List.is_baricenter == 1 & Project.Project_List.is_cinetic == 0);
Idx2use = Idx2use';

if isempty(Idx2use)
    disp('!!WARNING!!: Either DLC_data were not normalized for this project dataset or baricenters already computed, please verify the Project_List table')
end

% Set the start of the timer
t_start = []; t_stop = [];
t_start = tic;

% Initialize the progress bar
fprintf('Baricentering progress:   0%%');

% Set imaginary number
i = sqrt(-1);

%Loop normalization
for v = Idx2use

    % Load the normalize coordinate table
    Norm_DLC_output = [];
    load([Project.Path.Coordinates,filesep, Project.Project_List.Video_List{v},'.mat']);

    % Create the variable that will be done
    Baricenter_speed = zeros(height(Norm_DLC_output),1); Baricenter_angle = zeros(height(Norm_DLC_output),1); Baricenter_acceleration = zeros(height(Norm_DLC_output),1); Baricenter_jerk = zeros(height(Norm_DLC_output),1);
    Baricenter_angular_speed = zeros(height(Norm_DLC_output),1); Baricenter_angular_acceleration = zeros(height(Norm_DLC_output),1);

    % Loop time to compute speed
    for t = 2:height(Norm_DLC_output)
        Movement_Vector = [];
        Movement_Vector = [Norm_DLC_output.Baricenter_x(t)-Norm_DLC_output.Baricenter_x(t-1); Norm_DLC_output.Baricenter_y(t)-Norm_DLC_output.Baricenter_y(t-1)];

        Imag_Vec = [];
        Imag_Vec = Movement_Vector(1,1) +i*Movement_Vector(2,1);

        Baricenter_speed(t) = abs(Imag_Vec);
        Baricenter_angle(t) = angle(Imag_Vec);
    end

    Baricenter_acceleration ([2:end],1)= diff(Baricenter_speed);
    Baricenter_jerk ([2:end],1) = diff(Baricenter_acceleration);

    Baricenter_angular_speed ([2:end],1) = abs(angle(exp(i*diff(Baricenter_angle))));
    Baricenter_angular_acceleration ([2:end],1) = angle(exp(i*diff(Baricenter_angular_speed)));

    % add variable to table
    Norm_DLC_output = addvars(Norm_DLC_output, Baricenter_speed, Baricenter_acceleration, Baricenter_jerk, Baricenter_angle, Baricenter_angular_speed, Baricenter_angular_acceleration);

    %save the new table
    save([Project.Path.Coordinates, filesep, Project.Project_List.Video_List{v}], 'Norm_DLC_output', '-v7.3');

    writetable(Norm_DLC_output, [Project.Path.Coordinates, filesep, Project.Project_List.Video_List{v},'.csv']);

    % Update project
    Project.Project_List.is_cinetic(v) = 1;

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