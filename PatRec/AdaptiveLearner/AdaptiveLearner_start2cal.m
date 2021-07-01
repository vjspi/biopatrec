% ---------------------------- Copyright Notice ---------------------------
% This file is part of BioPatRec ??? which is open and free software under  
% the GNU Lesser General Public License (LGPL). See the file "LICENSE" for 
% the full license governing this code and copyrights.
%
% BioPatRec was initially developed by Max J. Ortiz C. at Integrum AB and 
% Chalmers University of Technology. All authors contributions must be kept
% acknowledged below in the section "Updates % Contributors". 
%
% Would you like to contribute to science and sum efforts to improve 
% amputees quality of life? Join this project! or, send your comments to:
% maxo@chalmers.se.
%
% The entire copyright notice must be kept in this or any source file 
% linked to BioPatRec. This will ensure communication with all authors and
% acknowledge contributions here and in the project web page (optional).
%
% -------------------------- Function Description -------------------------
% Set handles to process a recSession in a custom default manner 
% for later processing as patRec
% ------------------------- Updates & Contributors ------------------------
% [Contributors are welcome to add their email]
% 2021-06-15 / Veronika Spieker / Creation -
% 20xx-xx-xx / Author  / Comment on update


function AdaptiveLearner_start2cal()

% BioPatRec;
close all;
clear all;

gui_RecSes = GUI_RecordingSession;
handles_RecSes = guidata(gui_RecSes);
eventdata = [];

% Recording Parameters
% set(handles_RecSes.et_Nr, 'String', '3');
% set(handles_RecSes.et_Tc, 'String', '10');
% set(handles_RecSes.et_Tr, 'String', '5');
set(handles_RecSes.et_Nr, 'String', '1');
set(handles_RecSes.et_Tc, 'String', '1');
set(handles_RecSes.et_Tr, 'String', '1');

set(handles_RecSes.et_msg, 'Value', [1 2 5 6 7 8]);         % Hand motions: OH, CH, P, S, PG, Rest

%% Start Recording
GUI_RecordingSession('pb_Record_Callback',gui_RecSes, eventdata, handles_RecSes);

%% Select Myo and start Recording!


%% Wait for AFE selection
% gui_AFEsel = handles_RecSes.AFE_GUI;
% handles_AFEsel = guidata(gui_AFEsel);
% 
% set(handles_AFEsel.pm_name, 'Value', 2); % corresponds to "Thalmic MyoBand (Quat incl. Real-time)"
% GUI_AFEselection('pm_name_Callback', gui_AFEsel, eventdata, handles_AFEsel);


% fast = 0;
% h1 = GUI_Recordings(fast); 
% hGUI_Rec = guidata(h1);
% nM = 6;
% nR = 3;
% cT = 10,
% rT = 5;
% afeSettings.channels = 8;
% afeSettings.sampleRate = 200;
% afeSettings.name = 'Thalmic MyoBand (Quat incl. Real-time)';
% afeSettings.ComPortType = 'NI';
% afeSettings.prepare = 0;
% vreMovements = [];
% mov = {'Open Hand'; 'Close Hand'; 'Pronation'; 'Supination'; 'Pinch Grip'; 'Rest' }
% % 
% [cdata, sF] = RecordingSession(nM,nR,cT,rT,mov,hGUI_Rec,afeSettings,0,vreMovements,0,0,0,0,0);%Fs,Ne,Nr,Tc,Tr,Psr,msg,EMG_AQhandle,rampParams);

% [cdata, sF] = RecordingSession(nM,nR,cT,rT,mov,hGUI_Rec,AFE_settings,get(handles.cb_trainVRE,'Value'),vreMovements,get(handles.cb_VRELeftHand,'Value'),movRepeatDlg,useLeg,rampStatus,rampParams);%Fs,Ne,Nr,Tc,Tr,Psr,msg,EMG_AQhandle,rampParams);
% RecordingSession(nM, nR, cT, rT, mov, handles, afeSettings, 0, 0, 0, movRepeatDlg, 0, 0)

% GUI_AFEselection('pb_record_Callback') % Recording is started manually
% Continues in into RecordingSession.m
end

