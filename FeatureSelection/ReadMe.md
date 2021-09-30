### IMU Feature Integration

Next to the EMG feature extraction provided by Matlab, the newly integrated IMU data needs to be included in the feature set. 
BioPatRec generates multiple features (predefined in a separate file \textit{features.def}) for all available segments. 
These are all loaded into the pattern recognition module and can be selected in the user interface for further processing. 
The feature extraction process was adapted to identify if IMU data is available in the recording set. In that case, an extended feature file (_featuresIMU.def_). 
The extended file includes additional IMU feature definitions, which are marked with an _i_ as a prefix. 
Since this work focuses on orientational data, exclusively quaternions were extracted. 
By averaging the IMU valued during signal recording, the features were already provided as mean values per segment. 
The Euler angles were derived with **ZYX** as the order of rotation.
