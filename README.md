# Multi-modal Adaptive Learner for Hand Motion Classification

Paper Title:

Journal: 

Authors: Veronika Joanna Spieker, Amartya Ganguly, Cristina Piazza, and Sami Haddadin


# Repository overview

BioPatRec's original documentation and instruction can be found here: https://github.com/biopatrec/biopatrec/wiki

Adjustments were made within the same structure.

This forked repository (vjspi/biopatrec) extends the BioPatRec platform in two ways:
1. Integration of IMU data using a Myo Armband (Signal Recording/Signal Treatment/Feature Extraction Module)
2. Integration of an adaptive learner (Pattern Recognition Module)

## IMU Data
### IMU Recording
IMU sampling is included as new communication protocol in the Comm/Myoband folder and is linked to the selected device name in the Analog Front-End Selection (_GUI_AFEselection_)

Added options are:
1. Thalmic MyoBand (IMU) - uses the MyoBandSession_Mex file (based on https://github.com/mark-toma/MyoMex.git)
2. Thalmic MyoBand (Quat incl. real-time) - uses the MyoBandSession_IMU.m (based on MyoBandSession.m) - **recommended**

The first option allows the capture of all sampled IMU data points, while the second only stores the average of the current sample window set in the Recordings GUI (e.g. if the sample window is set to 0.5 s and the EMG sampling frequency is 200 Hz, ten data points are stored for EMG and the IMU value is averaged over this time period because the IMU is provided less frequently and without a reliable time stamp). Thalmic MyoBand (Quat incl. real-time) is the recommended option for this purpose because it allows real-time usage relevant for later online usage, 

![grafik](https://user-images.githubusercontent.com/80716904/134916102-92689f5b-67a9-42e2-afce-b0c13b24e739.png)

### IMU Feature Extraction
Generation of IMU features is included in the Signal Treatment module. If IMU data is detected, the _Position Estimation_ option is activated and can be selected. Predefined functions (here classification of y rotation into three segments, see paper) allows the generation of IMU labels. Different interpretations can be added by adjusting _GUI_SignalTreatment_ and extending the definitions of the position estimation function (SigTreatment/Position Estimation/EstimatePosition.m). 

Within the PatRec interface, the generated IMU features (according to _SigFeatures/featuresIMU.def_) can then be selected for further processing.

![grafik](https://user-images.githubusercontent.com/80716904/134928772-c84da526-f340-4538-8872-f0c024551185.png)

## Adaptive learner


## Running the script

Running the experimental protocol presented in the paper, requires the consecutive execution of three scripts in PatRec/AdaptiveLearner:
1. **AdaptiveLearner_start2cal.m**: Initiates the calibration phase. The subject is instructed during a recording session (_GUI_RecordingSession_) to conduct predefined hand motions in a given set of positions (parameters can be adjusted within this script). The recorded EMG and/or IMU data is stored with the visual command and saved as cal.mat 
2. **AdaptiveLearner_cal2fam.m**: Initiates the familiarization phase - a series of TAC tests for a predefined number of combinations. When external factors need to be changed, a window indicates the desired change and the protocol only proceeds after user confirmation. All data points recorded during the TAC tests is stored as fam.mat.
3. **AdaptiveLearner_fam2test.m**: Initiates the testing phase. The cal.mat and fam.mat files are loaded from the selected folder and used to generate to classifier models, one only based on the _cal_ data and one based on the combined data of _cal_ and _fam_ (see paper for data selection). Both models are stores as patRecAdapted.mat and used in the automatically initiated TAC test series. Results of the testing phase are saved as test.mat.

Data sets can be found here: https://github.com/vjspi/SubjectData.git

Warnings to avoid connectivity issues:
- Distance between USB adapter and Myo Armband should be as minimal as possible for the experiment 
- Restart computer or stop all processes (especially on Windows) before running the protocol (otherwise potential interruption of the MyoBand's datastream)

# Cite this work
