function wyb_norm_DLCdata(Project_Path)

% FUNCTION wyb_norm_DLCdata(Project_Path)
% This function will normalize the DLC Data table based on the OF
% coordinates
%
% INPUT:
%   - Project_Path: Path where you want to store results of toolbox
%
%                   !!BE CAREFUL!!
% !! This is only available for squared Open Field for now
%
% Matthieu Aguilera, Funsy Team, Sept 2023

% Load the project_info structure
load([Project_Path,filesep,'Project_info']);

% Find Index of Videos with frames non_extracted
Idx2use = [];
Idx2use = find(Project.Project_List.is_frame == 1 & Project.Project_List.is_OF_coord == 1 & Project.Project_List.is_norm == 0);
Idx2use = Idx2use';

if isempty(Idx2use)
    disp('!!WARNING!!: Either frames were not extracted, arena coordinates not determined or DLC_data already normalized for this project dataset, please verify the Project_List table')
end

%Loop normalization
for v = Idx2use

    % Set the start of the timer
    t_start = []; t_stop = [];
    t_start = tic;

    % First need to open the DLC table with only one title variable
    % concatenating two of the one in the original DLC output

    % Need to extract the name of the DLC file that can have some extension
    DLC_file_info = [];
    DLC_file_info = dir([Project.Path.DLC_output, filesep, Project.Project_List.Video_List{v},'*.csv']);

    DLC_file_name = [];
    DLC_file_name = DLC_file_info.name;

    % Create textscan format for next steps
    % Need to make a vector of %s the number of variable in DLC table so
    % number of bodypart x 3 (x, y, likelihood) + 1 (frames);

    textformat = [];
    for i = 1:(numel(Project.Bodyparts)*3+1)
        textformat = [textformat, '%s'];
    end

    % Open table for extracting var_names
    fid = fopen([Project.Path.DLC_output, filesep, DLC_file_name]);
    C = textscan(fid, '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', 'Delimiter', ',');

    % Creating cell vector of variable names
    Var = [];
    for c = 1:numel(C)
        Var{c} = [C{1,c}{2},'_', C{1,c}{3}];
    end

    % Replacing the first column that is now called Bodypart_coord by
    % 'frames' which is the real data
    Var{1} = 'Frames';

    % Import data table without variable title
    DLC_Data = readtable([Project.Path.DLC_output, filesep, DLC_file_name], 'NumHeaderLines',3,'ReadVariableNames',false );

    % Creating a vector representing the actual column titles of DLC_Data
    Old_vars = [];
    for i = 1:size(DLC_Data, 2)
        Old_vars{i} = ['Var',num2str(i)];
    end

    % Replace Variable title of DLC_Data
    DLC_Data = renamevars(DLC_Data,Old_vars,Var);

    % Now that DLC data are imported, we will normalize them thanks to the
    % coordinates and vectors computed in wyb_get_arena_coordinates

    % Load the coordinates from wyb_get_arena_coordinates
    load([Project.Path.Arena_Coordinates, filesep, Project.Project_List.Video_List{v}]);


    % Create the Table that will have the normalized data
    Sz = [1 size(DLC_Data,2)];
    varTypes = [];
    for i = 1:size(DLC_Data,2)
        varTypes{i} = 'double';
    end
    Norm_DLC_output = table('Size', Sz, 'VariableTypes', varTypes, 'VariableNames',Var);

    % Normalize the data for each frames and concatenate the temporary
    % table with the one previously created

    % Initialize the progress bar
    fprintf([Project.Project_List.Video_List{v},' Normalization progress:   0%%']);

    for t = 1:size(DLC_Data,1)
        for b = 1:numel(Project.Bodyparts)
            BodyP_coord(:,b) = [DLC_Data.([Project.Bodyparts{b},'_x'])(t); DLC_Data.([Project.Bodyparts{b},'_y'])(t)];
        end

        % First we realign the coordinate from the camera referential to
        % the Open Field Referential
        Realign_coord = []; New_origin = [];
        New_origin = BodyP_coord + Arena_Coordinates.Norm_var.OA_OC;
        Realign_coord = Arena_Coordinates.Norm_var.RM*New_origin;

        Norm_coord = [];

        % Normalize data taking X & Y length in account
        Norm_coord(1,:) = Realign_coord(1,:)./Arena_Coordinates.Norm_var.norm_unit_X;
        Norm_coord(2,:) = Realign_coord(2,:)./Arena_Coordinates.Norm_var.norm_unit_Y;


        Temp_Table = table('Size', Sz, 'VariableTypes', varTypes, 'VariableNames',Var);
        Temp_Table.(Var{1}) = t;

        for b = 1:numel(Project.Bodyparts)
            Temp_Table.([Project.Bodyparts{b},'_x']) = Norm_coord(1,b);
            Temp_Table.([Project.Bodyparts{b},'_y']) = Norm_coord(2,b);
        end
        Norm_DLC_output = [Norm_DLC_output; Temp_Table];

        clear Temp_Table;

        % Calculate the current progress percentage
        progress = [];
        progress = t / (size(DLC_Data,1)) * 100;

        % Update the progress bar in the command window
        fprintf('\b\b\b\b%3d%%', round(progress));
    end

    % Delete the junk first line of the table
    Norm_DLC_output(1,:) = [];

    % Add the likelihood data from the old table to the new one
    for b = 1:numel(Project.Bodyparts)
        Norm_DLC_output.([(Project.Bodyparts{b}),'_likelihood']) = DLC_Data.([(Project.Bodyparts{b}),'_likelihood']);
    end

    % Save the new table in .mat and .csv
    save([Project.Path.Coordinates, filesep, Project.Project_List.Video_List{v}], 'Norm_DLC_output', '-v7.3');

    writetable(Norm_DLC_output, [Project.Path.Coordinates, filesep, Project.Project_List.Video_List{v},'.csv']);

    % Update project
    Project.Project_List.is_norm(v) = 1;

    t_stop = toc(t_start);
    disp([' done in ', num2str(t_stop/60), ' min']);

    fprintf('\n'); % Print a newline to move to the next line after the loop
end

% Save updated project
save([Project_Path,filesep,'Project_info'], 'Project', '-v7.3');