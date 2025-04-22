# Project Title

Ros tools for the Messii dataset

## Description

Tools to create the rosbags from the standalone version of the Messii dataset
* messi_dataset_converter.py: Creates a robsbag from a trajectory
* run_create_dataset: Bash script to run the python program several times and convert the whole dataset

### Executing program

* bash run_create_dataset <path to the source folder of the dataset> <Type of data to convert>

For example, if dataset is in Dataset folder in the home directory : 
bash run_create_dataset /home/lionel/Dataset all

Options of type of data to convert "all", "Robot_identification", "Load_identification", "Sensor_identification", "pHRI"
