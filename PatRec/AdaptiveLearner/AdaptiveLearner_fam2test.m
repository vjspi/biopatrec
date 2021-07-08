% ---------------------------- Copyright Notice ---------------------------
% This file is part of BioPatRec ? which is open and free software under 
% the GNU Lesser General Public License (LGPL). See the file "LICENSE" for 
% the full license governing this code and copyrights.
%
% BioPatRec was initially developed by Max J. Ortiz C. at Integrum AB and 
% Chalmers University of Technology. All authors? contributions must be kept
% acknowledged below in the section "Updates % Contributors". 
%
% Would you like to contribute to science and sum efforts to improve 
% amputees? quality of life? Join this project! or, send your comments to:
% maxo@chalmers.se.
%
% The entire copyright notice must be kept in this or any source file 
% linked to BioPatRec. This will ensure communication with all authors and
% acknowledge contributions here and in the project web page (optional).
%
% -------------------------- Function Description -------------------------
% BioPatRec Data Treatment Process
%
% Input: Directory which includes a "cal" (calibration in RecSession) file 
% and a "fam" (familirization - no labels - fastRecSession) file
%
% ------------------------- Updates & Contributors ------------------------
% [Contributors are welcome to add their email]
% 2014-0x-xx / Morten K.    / Creation
% 2021-06-21 / Veroniks S.  / Adaptation to execute an adaptive Learning
%                           process

function AdaptiveLearner_fam2test()

close all;  
clear all;

path = uigetdir;
% path = 'C:\Users\spieker\LRZ Sync+Share\MasterThesis\20_Coding\DataSets\30_MultiPosVisualization';
fileAdapt = 'fam_tacTest1';

load([path,'\',fileAdapt], 'tacTest');
handles.patRec = tacTest.patRec;
alg = 'Discriminant A.';
% set(button, 'String', 'Wait');

%% Check if familiarization condition is fulfilled
compRateMean = mean(tacTest.compRate);
if compRateMean < 0.6
    errordlg('Minimum completion rate not achieved','Error');
end


%% ######################### TESTING ###################################### 

%% Augment
% For FastRecSessiom
% fastRecSession.tdata = cdata;
% fastRecSession.idata = idata(:,1:4);  

% For TacTest
handles.fam.tacTest = tacTest;
nSMajVote = 5;
[patRecAdapted, handles] = AugmentPatRec(handles, alg, nSMajVote);

%Show how many samples were addedcl
disp('Added samples:');
disp(patRecAdapted.patRecAug.nSAddAll);
disp('---------------');

% Update
handles.patRec = patRecAdapted; 

% Save adapted patRec
save([path, '\patRecAdapted'], 'patRecAdapted');

%% TESTING
% Load patRec
RealTimeFigure = Load_patRec(handles.patRec, 'GUI_TestPatRec_Mov2Mov',1);
RealTimeHandles = guidata(RealTimeFigure);

GUI_TestPatRec_Mov2Mov('pb_socketDisconnect_Callback', RealTimeFigure, [], RealTimeHandles);
GUI_TestPatRec_Mov2Mov('pb_socketConnect_Callback', RealTimeFigure, [], RealTimeHandles);

% Do TAC Test
TacValues_Test.nTrials = 6; % three trials for each algorithm with different weight each
TacValues_Test.nRep = 1; % one run using different positons
TacValues_Test.testTime= 15;  % in seconds
TacValues_Test.allowance = 8;  % in degrees
TacValues_Test.distance = 60;  % in degrees -> could be a vector such as [10 20 30] - then allowance need to be the same
TacValues_Test.dwellT = 1;   % in seconds
% Save mainGUI handle to guidata of GUI_TacTest
GUI = eval('GUI_TacTest');
TacHandles = guidata(GUI);
TacHandles.mainGUI = RealTimeFigure;

changeTacValues(TacHandles, GUI, TacValues_Test);
guidata(GUI,TacHandles);

%% Conduct TAC-Test -> saves results into same folder

end

% Change values
function changeTacValues(TacHandles, GUI, TacValues)
set(TacHandles.tb_trials, 'String', num2str(TacValues.nTrials));
set(TacHandles.tb_repetitions, 'String', num2str(TacValues.nRep));
set(TacHandles.tb_executeTime, 'String', num2str(TacValues.testTime));
set(TacHandles.tb_allowance, 'String', num2str(TacValues.allowance));
set(TacHandles.tb_distance, 'String', num2str(TacValues.distance));
set(TacHandles.tb_time, 'String', num2str(TacValues.dwellT));

guidata(GUI,TacHandles);

end
