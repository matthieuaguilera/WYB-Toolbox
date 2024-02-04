function wyb_extract_video_frame(Project_Path)

% FUNCTION wyb_extract_video_frame(Project)
% This function will extract one frame of each videos of the wyb project
% This frames will be used to set the coordinates for the OF normalization
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
Idx2use = find(Project.Project_List.is_frame == 0);
Idx2use = Idx2use';

% Extract one frame and save it for each video of the video list
for v = Idx2use
    Vid = []; Frame = [];
    Vid = VideoReader([Project.Path.Video,filesep,(Project.Project_List.Video_List{v}),Project.Video_format]);

    Frame = read(Vid, randi([1000 12000],1));

    imwrite(Frame, [Project.Path.Frames,filesep,Project.Project_List.Video_List{v},'.jpg']);
    Project.Project_List.is_frame(v) = 1;
end

% save actualised project
save([Project_Path,filesep,'Project_info'], 'Project', '-v7.3');