#######################################################################################
# File: est_std_dev

## Description

Computing of estimate of variance and relative standard deviation.

#######################################################################################
# File: filter_messii.m

## Description

Tool to Filter data with the following stages:
- Butterworth Filter 
- Numerical differentiation of position to obtain velocities and accelerations
- Border Effect treatement
- Downsample
- Elimination of measurements around 0 speed


## Instructions
Change the coefficients under "USER-DEFINED PARAMETERS" to indicate the folder path of the raw files and to tune the filter as wished.


## Output
Folder with filtered signals in .txt files.
.m file with all the filtered signals.

#######################################################################################
# File: LSE_J4

## Description
Algorithm used to obtain the results of identification of joint 4 for the paper.

#######################################################################################
# File: PARAMS

## Description

Array of name of parameters.

#######################################################################################
# File: Regressor_Builder.m

## Description

Tool to build the regressor matrix based on the inverse dynamic model of the manipulator.


## Instructions
Indicate the name of the path of the .m file with the filtered signals under "USER-DEFINED PARAMETERS".


## Output
.m file with all the filtered signals and the regressor matrix.

#######################################################################################
# File: Sequential_Joint_4_Inertia_Filtered_all

## Description

Output of Regressor_Builder for a specific trajectory.


#######################################################################################
# File: YNFUNCT

## Description

Matlab function with the function to be able to build the regressor matrix of the inverse dynamic model of the robot.