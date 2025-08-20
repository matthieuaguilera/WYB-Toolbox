# WYB-Toolbox
WYB is a tool to postprocess behavioral data extracted from DeepLabCut to obtain Behavior apparatus normalized coordinates, Animal cinetics in the apparatus and posture normalized coordinates.

This toolbox is described in the Aguilera et al.,2025 paper mentionned at the end of the document in "Reference and Citation"

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
Two specific bodyparts points need to be choose:
- the 'Central_bodypart, which be the bodypart considered at the most central point of the animal (e.g. the body)
- the "Orientation" bodypart (e.g. the neck), which is one that will fix the orientation of the animal at each frames by a "center" "orientation" vector
Central and Orientation Bodyparts need to be bodyparts listed in the 'Bodyparts' vector from the begining of the pipeline.
The baricenter will be the average of these 2 points

```
wyb_get_baricenter(Project_Path, 'Central_Bodypart', 'Orientation_Bodypart');
```

### Compute Baricenter cinetic

```
wyb_get_cinetic(Project_Path);
```
This will compute speed and acceleration of the baricenter. It will also compute the angel, angular speed and angular acceleration.

### Get posture coordinates

```
wyb_baricenter_realignment(Project_Path);
```
This will allow to normalize each bodyparts coordinates by the baricenter and align it with the orientation fixed. New coordiantes for each bodyparts are thus created that are "posture" coordinates, meaning movement of the skeleton of the animal without taking into account movement in the environment.

## Reference and Citation
Aguilera M, Mathis C, Herbeaux K, Isik A, Faranda D, Battaglia D, Goutagny R; 40 Hz light stimulation restores early brain dynamics alterations and associative memory in Alzheimer’s disease model mice. Imaging Neuroscience 2025; 3 IMAG.a.70. 
doi: https://doi.org/10.1162/IMAG.a.70






