function wyb_create_project(Project_Path, DLC_output_Path, Video_Path, Bodyparts)

% FUNCTION wyb_create_project(Project_Path, DLC_output_path, Video_Path)
% Starting point of Watch Your Behavior (WYB) Toolbox
% Create a Folder in "Project Path" where output of tool box will be
% stored
%
% INPUTS:
%   - Project_Path: Path where you want to store results of toolbox
%   - DLC_output_path: Path where are stored your DeepLabCut csv files
%   - Video_Path: Path where are stored your videos
%   - Bodyparts: Cell Vector of the differents Bodyparts as indicated in
%     DLC
%
% !! BE CAREFUL !!
% If you run this toolbox on MacOS, video file .avi is not supported and
% some error can be encountered with some .MP4, favorise .mov file for the videos
%
% Matthieu Aguilera, Funsy Team, Sept 2023

% Create project folder
mkdir(Project_Path);

% Create folders in the project folder for frame extraction, table results
% and info

mkdir([Project_Path, filesep, 'Video_frames']);
mkdir([Project_Path, filesep, 'Coordinates']);
mkdir([Project_Path, filesep, 'Arena_Coordinates']);
% Create the list of video names for looping all others function
List_File = dir(Video_Path);
List_File = List_File(~cellfun(@(x) x==1, {List_File.isdir})); % Remove line non corresponding to files
List_File = List_File(~cellfun(@(x) strcmp(x, '.DS_Store'), {List_File.name})); % Remove DS_store cache file if running on mac


% Create a table that will have the name of video and the status to adapt
% for when need to add videos

Video_List = {};
for f = 1:length(List_File)
    [~, name, ~] = fileparts(List_File(f).name);
    Video_List{f,1} = name;
end

Video_format = [];
[~, ~, Video_format] = fileparts(List_File(1).name);

is_frame = zeros(length(Video_List),1);
is_OF_coord = zeros(length(Video_List),1);
is_norm = zeros(length(Video_List),1);
is_baricenter = zeros(length(Video_List),1);
is_cinetic = zeros(length(Video_List),1);
is_baricenter_realigned = zeros(length(Video_List),1);

Project_List = [];
Project_List = table(Video_List, is_frame, is_OF_coord, is_norm, is_baricenter, is_cinetic, is_baricenter_realigned);
% Create an Project structure that will contain all informations for
% next functions

Project.Path.Project = Project_Path;
Project.Path.Video = Video_Path;
Project.Path.DLC_output = DLC_output_Path;
Project.Path.Frames = [Project_Path, filesep, 'Video_frames'];
Project.Path.Coordinates = [Project_Path, filesep, 'Coordinates'];
Project.Path.Arena_Coordinates = [Project_Path, filesep, 'Arena_Coordinates'];

Project.Project_List = Project_List;
Project.Creation_Date = datetime('now', 'Format','dd-MMM-yyyy');
Project.Bodyparts = Bodyparts;
Project.Video_format = Video_format;

% Save the structure
save([Project_Path,filesep,'Project_info'], 'Project', '-v7.3');