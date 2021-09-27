# Multi-modal Adaptive Learner for Hand Motion Classification

Paper Title:

Journal: 

Authors:


# Repository overview

BioPatRec's original documentation and instruction can be found here: https://github.com/biopatrec/biopatrec/wiki

Adjustments were made within the same structure.

This forked repository (vjspi/biopatrec) extends the BioPatRec platform in two ways:
1. Integration of IMU data using a Myo Armband (Signal Recording Module)
2. Integration of an adaptive learner (Pattern Recognition Module)

## IMU Recording
IMU sampling is included as new communication protocol in the Comm/Myoban folder and is linked to the selected device name in the Analog Front-End Selection (_GUI_AFEselection_)

Added options are:
1. Thalmic MyoBand (IMU) - uses the MyoBandSession_Mex file (based on https://github.com/mark-toma/MyoMex.git)
2. Thalmic MyoBand (Quat incl. real-time) - uses the MyoBandSession_IMU.m (based on MyoBandSession.m) - **recommended**

The first option allows the capture of all sampled IMU data points, while the second only stores the current average of a sample window (set in the Recordings GUI). Because the latter allows real-time usage relevant for later online usage, Thalmic MyoBand (Quat incl. real-time) is the recommended option for this purpose.

![grafik](https://user-images.githubusercontent.com/80716904/134916102-92689f5b-67a9-42e2-afce-b0c13b24e739.png)


## Adaptive learner

## Running the script

Running the experimental protocol presented in the paper, requires the consecutive execution of three scripts in PatRec/AdaptiveLearner:
1. **AdaptiveLearner_start2cal.m**: 
2. **AdaptiveLearner_cal2fam.m**:
3. **AdaptiveLearner_fam2test.m**:


Warnings: 
- Distance between USB adapter and Myo Armband should be as minimal as possible for the experiment (otherwise connection issues might occur)
- Restart computer or stop all processes (especially on Windows) before running the protocol to avoid unwanted interruption within the MyoBand's datastream

# Cite this work
