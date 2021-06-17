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


function handles = CustomDefault(handles, dataset)


%% RecSession 
cTp = 1.0;
addArtifact = 0; % None
%....define further information

%% SigTreated
trP = 0.4;      
vP = 0.2;
tP = 0.4;       % Time window in s
wOverlap = 0.05;      % Overlap in s

posEstimation = '3 Positions';

%% SigFeatures
featSel = {'tmabs';'twl';'tzc';'tslpch2'};
alg = 'Discriminant A.';
type = 'linear';

%% RecSession to SigTreated

if strcmp(dataset, 'recSession')
    
    set(handles.et_cTp ,'String',num2str(cTp));
    set(handles.cb_AddArtifact ,'Value',addArtifact);
 
end

if strcmp(dataset, 'sigTreated')
    
    nw = str2double(get(handles.et_nw,'String'));

    set(handles.et_trP, 'String', num2str(trP));
    set(handles.et_vP,'String', num2str(vP));
    set(handles.et_tP,'String', num2str(tP));
    
    trN = ceil(trP * nw);
    set(handles.et_trN,'String',num2str(trN));
    
    vN = fix(vP * nw);
    set(handles.et_vN,'String',num2str(vN));

%     tN = fix(tP * nw);
    tN = nw - trN - vN;
    set(handles.et_tN,'String',num2str(tN));
    
    if (trN + vN + tN) > nw
        disp('Too many sets selected')
    end

    set(handles.t_totN,'String',num2str(trN+vN+tN));
    set(handles.t_totP,'String',num2str(trP+vP+tP));
    
    % Set position data
    allPosEst = get(handles.pm_posEstimation, 'String');
    iPosEst = find(strcmp(allPosEst,posEstimation));
    set(handles.pm_posEstimation, 'Value', iPosEst);
 
end


%% Settings for patRec creation
if strcmp(dataset, 'sigFeatures')
    
    % Signal features
    allFeatures = get(handles.lb_features,'String');
    for j=1:length(featSel)
        idxFeat(j) = find(strcmp(allFeatures,featSel(j)));
    end
    set(handles.lb_features,'Value', idxFeat);
    
    % Algorithm
    allAlg      = get(handles.pm_SelectAlgorithm,'String'); 
    idxAlg      = find(strcmp(allAlg,alg));
    set(handles.pm_SelectAlgorithm,'Value', idxAlg);
    % Callback function to enable correct selection of algorithm type
    GUI_PatRec('pm_SelectAlgorithm_Callback', handles.output, [], handles);
    
    allTypes    = get(handles.pm_SelectTraining,'String');
    idxAlg      = find(strcmp(allTypes,type));
    set(handles.pm_SelectTraining,'Value', idxAlg);    
    GUI_PatRec('pm_SelectTraining_Callback', handles.output, [], handles);
    
end

% if strcmp(dataset, 'patRec')
%     %% Augment data
% end

    
% other data from recording

% Pre-Processing

%% SigTreated to SigFeatures
% Find second dataset and save in handles


% Time windows
% If Position -> 3Pos
% sets per movement -> tSet for beginning close to 0?

% %% SigFeatures to patRec
% 
% RecSes = GUI_RecordingSession;
% handles_RecSes = guidata(RecSes);
% eventdata = [];
% 
% % Recording Parameters
% set(handles_RecSes.et_Nr, 'String', '2');
% set(handles_RecSes.et_Tc, 'String', '5');
% set(handles_RecSes.et_Tr, 'String', '5');
% 
% set(handles_RecSes.et_msg, 'Value', [1 2 3 4]);         % Hand motions
% 
% %% Start Recording
% GUI_RecordingSession('pb_Record_Callback',RecSes, eventdata, handles_RecSes);
% 
% 
% %% Wait for AFE selection
% % GUI_AFEselection('pb_record_Callback'
% % GUI_AFEselection_OpeningFcn(hObject, eventdata, handles, varargin)
% 
% 
% %% 
% 
% 
% % H('pb_Record_Callback',RecSes, eventdata, handles_RecSes)
% 
% % H = GUI_RecordingSession('et_Fs_Callback''et_Nr', 'String', '2');
% %  et_Fs_Callback(hObject, eventdata, handles)
% disp('ready');
% 
% % GUI_RECORDINGSESSION('CALLBACK',hObject,eventData,handles,...)
% 
% % Set experiment parameters
% % set(handles.et_Nr,'String','2')
% 
% end

