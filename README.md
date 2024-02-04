# WYB-Toolbox
WYB is a tool to postprocess behavioral data extracted from DeepLabCut to obtain Behavior apparatus normalized coordinates, Animal cinetics in the apparatus and posture normalized coordinates.

## Preparation
Need to store in a file all your original video in avi or mp4 format
Need to store in anor-ther file all your csv tables extracted from DeepLabCut
NAme of videos and table need to match for each trial

## Define Paths and settings for the toolbox
- Project_Path: the path where you want the project to be created;
- Video_Path: The path where all your videos are stored
- DLC_output_Path: The path where all your DeepLabCut data in csv table files are stored
- Bodyparts: The names of the different part of the skeleton called bodyparts you used in DeepLabCut

## Pipeline

### Create a project
```
wyb_create_project(Project_Path, DLC_output_Path, Video_Path, Bodyparts);
```


### Extract Video frames

```
wyb_extract_video_frame(Project_Path);
```
This will extract one frame per videos to be used in following functions to normalize the data

### Get Arena Coordinates

```
wyb_get_arena_coordinates(Project_Path);
```
For each video, click on the 4 corners of the open field in the following order:
- Top Left
- Top Right
- Bottom Right
- Bottom Left
This will get the arena coordinates for following normalization

### Normalize DeepLabCut Data

```
wyb_norm_DLCdata(Project_Path);
```
This will normalize the Data extracted by DeepLabCut by the coordinates of the OpenField, taking in acount the length and the angle of the openfield.
Videos with different zoom ratio or with the apparatus a bit moved can thus be comparable.

### Extract the mean position of the animal: the baricenter

The baricenter will be the "average" of the skeleton, used to have the global position and speed of the animal in the apparatus but also further used to normalize the skeleton to have the "posture" of the animal.
Two specific points need to be choose:
- the "Center" point, which be the one considered at the most central point of the animal (e.g. the body)
- the "Orientation" point (e.g. the neck), which is one that will ix the orientation of the animal at each frames by a "center" "orientation" vector
The baricenter will be the average of these 2 points

```
wyb_get_baricenter(Project_Path, 'Body', 'Neck');



