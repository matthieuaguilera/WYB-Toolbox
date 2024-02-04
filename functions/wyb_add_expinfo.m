function wyb_add_expinfo(Project_Path, Exp_Info)

% FUNCTION wyb_add_exp_Info(Project_Path)
% This function will create a table repertoring all the videos, and adding
% columns for different variables, these variables can then be manually
% edited. This will allow to realise analyses per conditions.
% If the condition table do not exist it will create it, if it already
% exist it will add the conditions after.
%
% Also, a condition nb of landmark is automatically created that need to be
% completed to use wyb_add_landmark function
%
% Landmark can be an object in a novel object task or a plateform in other
% tasks
%
% INPUT:
%   - Project_Path: Path where you want to store results of toolbox
%   - Exp_Info: cell vector containing the different names of the
%     conditions
%     !!!IF the condition list already exist and want to add conditions, only
%     write the conditions you want to add!!!
%
%
% Matthieu Aguilera, Funsy Team, Sept 2023

% Load the project_info structure
load([Project_Path,filesep,'Project_info']);

% Create Exp_Info Folder Path
if ~isfield(Project.Path, 'Exp_Info')
    Project.Path.Exp_Info = [Project_Path, filesep,'Exp_Info'];
end

% Create Condtions Folder
if ~exist(Project.Path.Exp_Info)
    mkdir(Project.Path.Exp_Info);
end

% Create Table for condition when no previous ones exist
if ~exist([Project.Path.Exp_Info, filesep,'Exp_Info_List.csv'])
    Video_List = {};
    Video_List = Project.Project_List.Video_List;

    % Creat vector of variable names for the table
    Var_Names = {'Video_List', 'nb_landmark'};
    Var_Names = [Var_Names, Exp_Info];

    % Set the variable types for each variables to create the table
    Var_type = [];
    for v = 1:numel(Var_Names)
        Var_type = [Var_type, "string"];
    end

    % Create the empty tables with the good variable names
    Exp_Info_List = table('Size',[length(Video_List), numel(Var_Names)], 'VariableTypes', Var_type, 'VariableNames',Var_Names);

    % Set Video List in the table
    Exp_Info_List.Video_List = Video_List;

    % Set Vector of object number
    Exp_Info_List.nb_landmark = zeros(height(Exp_Info_List),1);

else % Update pre_existing Exp_Info table
    Exp_Info_List = readtable([Project.Path.Exp_Info, filesep,'Exp_Info_List.csv'], 'FileType', "text",'Delimiter', ",", 'VariableNamingRule', 'preserve');

    % Create empty nan new variables in the table
    for Cond = 1:numel(Exp_Info)
        Exp_Info_List.(Exp_Info{Cond}) = nan(height(Exp_Info_List),1);
    end
end

%save Exp_Info list in csv to be edited manually
writetable(Exp_Info_List, [Project.Path.Exp_Info, filesep,'Exp_Info_List.csv'], 'Delimiter',",");


% Save Updated project
save([Project_Path,filesep,'Project_info'], 'Project', '-v7.3');