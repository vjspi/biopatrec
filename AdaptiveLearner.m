% Adaptive learning test script


BioPatRec;

RecSes = GUI_RecordingSession;
handles_RecSes = guidata(RecSes);
eventdata = [];

% Recording Parameters
set(handles_RecSes.et_Nr, 'String', '2');
set(handles_RecSes.et_Tc, 'String', '5');
set(handles_RecSes.et_Tr, 'String', '5');

set(handles_RecSes.et_msg, 'Value', [1 2 3 4]);         % Hand motions

%% Start Recording
GUI_RecordingSession('pb_Record_Callback',RecSes, eventdata, handles_RecSes);


%% Wait for AFE selection
% GUI_AFEselection('pb_record_Callback'
% GUI_AFEselection_OpeningFcn(hObject, eventdata, handles, varargin)


%% 


% H('pb_Record_Callback',RecSes, eventdata, handles_RecSes)

% H = GUI_RecordingSession('et_Fs_Callback''et_Nr', 'String', '2');
%  et_Fs_Callback(hObject, eventdata, handles)
disp('ready');

% GUI_RECORDINGSESSION('CALLBACK',hObject,eventData,handles,...)

% Set experiment parameters
% set(handles.et_Nr,'String','2')



