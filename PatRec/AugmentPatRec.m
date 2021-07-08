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
% Function to calculate a classifier with an expanded data set
% Input:    handles:    must include the previous patRec and an additional
%                       recording Set (either to classify or including
%                       labels)
%           varargin:   Parameters for Algorithm Selection &  Majority 
%                       Voting (Post-Processing)
% Output:   patRec:     With new field "patRecAug" with two classifiers
%
% ------------------------- Updates & Contributors ------------------------
% [Contributors are welcome to add their email]
% 2021-06-15 / Veronika Spieker / Creation - Made an expanded routine for an
% augmented classifier
% 20xx-xx-xx / Author    / Comment on update

function [patRec, handles] = AugmentPatRec(handles, varargin)

if ~isempty(varargin)
    alg = varargin{1};
    nSMajVote = varargin{2};                
else 
    % Default Settings
    alg = 'Discriminant A.';
    nSMajVote = 1;
end
% patRecCal is the initial model after calibraton, 
% patRecAug is the model after additional data is fed
patRecCal = handles.patRec;   

% Load stacked data (rather than sigFeatures -> this ensures that the same
% randomization was used)
trSets = patRecCal.Sets.trSets; trOuts = patRecCal.Sets.trOuts; 
vSets = patRecCal.Sets.vSets; vOuts = patRecCal.Sets.vOuts; 
tSets = patRecCal.Sets.tSets; tOuts = patRecCal.Sets.tOuts; 

nM = patRecCal.nM;
nP = length(patRecCal.pos.idx);

% alg = patRecCal.patRecTrained.algorithm;   
% idxAlg = get(handles.pm_SelectAlgorithm, 'Value');
% allAlg = get(handles.pm_SelectAlgorithm, 'String');
tType = patRecCal.patRecTrained.training;

if isfield(patRecCal,'algConf')
    algConf = patRecCal.algConf;
else
    algConf = [];
end

%% Different input file options: 
% Fast recSession where idata & cdata are included -> Create labels
if isfield(handles.fam, 'tdata') && isfield(handles.fam, 'cdata')
    tDataNew = dataStruct.tdata;
    quatDataNew = dataStruct.idata;
    
    %% Segment acquired data
    tWsamples = patRecCal.tW * patRecCal.sF;          % number of samples per window 
    oS = patRecCal.wOverlap * patRecCal.sF;           % number of samples corresponding overlay
    nSmp = length(tDataNew);
    nCh = size(tDataNew, 2);
    nImu = size(quatDataNew, 2);

    % Number of windows available
    if oS == 0
        nW = fix(nSmp/tWsamples);
    else 
        offset = ceil((patRecCal.tW-patRecCal.wOverlap)/patRecCal.wOverlap);
        nW = fix(nSmp/oS)-offset;  
    end

    trSetsFam = zeros(tWsamples, nCh, nW);  %Initialize number of training matrices
    % trFeatFam = zeros(nW, nCh*length(patRecCal.selFeatures));     % Undefined because IMU and EMG features vary in length

    imuSetsAug = zeros(tWsamples, nImu, nW);
    trImuFam = zeros(nW, nImu);
    % trPosAug = zeros(nW, 1);

    for i = 1 : nW
        iidx = 1 + (oS * (i-1));
        eidx = tWsamples + (oS *(i-1));
        trSetsFam(:,:,i) = tDataNew(iidx:eidx,:);           % Raw data
        iSetsFam(:,:,i) = quatDataNew(iidx:eidx,:);         % Raw data of IMU
        trFeatFam(i,:) = SignalProcessing_RealtimePatRec(trSetsFam(:,:,i), patRecCal, iSetsFam(:,:,i));  % Processed and features extracted

        imuSetsAug(:,:,i) = quatDataNew(iidx:eidx,:); 
        % Direct processing -> how to combine with selection? Currently no
        % preprocessing -> save iFilter from preProcessing
        trImuFam(i,:) =  mean(imuSetsAug(:,:,i));
    end
    
    %% Classify/Evaluate
    outMov = zeros(nW,1);
    outPos = zeros(nW, 1);

    %% Floor noise
    % Only predict when signal is over floor noise?
    if(isfield(patRecCal,'floorNoise'));

        for i = 1:nW
            augSet = trFeatFam(i,:);
            meanFeature1 = mean(augSet(1:size(patRecCal.nCh,2)));
            fnoiseDiv = 1;
            if meanFeature1 < (patRecCal.floorNoise(1)/fnoiseDiv);
                outMov(i) = patRecCal.nOuts;
    %             outVector = zeros(patRecCal.nOuts,1);
    %             outVector(end) = 1;
            else
                 % Apply feature reduction
                augSet = ApplyFeatureReduction(augSet, patRecCal);
                % One shoot PatRec
                [outMov(i), ~] = OneShotPatRecClassifier(patRecCal, augSet);
            end   
        end

    else
        % If no floor noise
        for i = 1:nW
            augSet = trFeatFam(i,:);
            % Apply feature reduction
            augSet = ApplyFeatureReduction(augSet, patRecCal);
            % One shoot PatRec
            [outMov(i), ~] = OneShotPatRecClassifier(patRecCal, augSet);        
        end
    end

    for i = 1:nW
        [outMov(i), ~]  = OneShotPatRecClassifier(patRecCal, trFeatFam(i,:));
        % Evaluate with certainty?
        outPos(i,1)     = OneShotPositionEstimation(patRecCal.pos,trImuFam(i,:));
    end

    % Plot to test feasibility
    % h = figure;
    % hold on;
    % plot(trPosAug);
    % hold off
    
% tacTest with sample data and labels
elseif isfield(handles.fam, 'tacTest') 
    
    famTacTest = handles.fam.tacTest;
    % if TacTest already provides segmented data with labels
    
    trSegFam = famTacTest.tdata;       % Feature segments - extract features only for needed ones
    imuSetsAug = famTacTest.idata;      % Imu segments
       
    nW = size(trSegFam, 3);            % Number of windows/samples
    nImu = size(imuSetsAug, 2);         % Number of IMU channesl
    
    trImuFam = zeros(nW, nImu);         % Initialization of IMU Features
    outPos = zeros(nW, 1);
       
    % Position estimation
    for i = 1:nW
        trImuFam(i,:) =  mean(imuSetsAug(:,:,i));       % IMU Feature (mean)
        outPos(i,1) =  OneShotPositionEstimation(patRecCal.pos,trImuFam(i,:));
    end
    
    % Motion estimation (already during TAC Test)
    outMov = famTacTest.labels';

else 
       disp('### NO VALID FAMILIARIZATION SET ! ###')
       errordlg('That was not a valid familiarization set','Error');
end

%% Find desired data
idxAdapt = patRecCal.idxAdapt;      % Desired augmentation
idxFamPhase = [outPos, outMov];

trFeatFam_Sel = [];
trOutFam_Sel = [];

% Total number of samples available from data set
nSTot = zeros(nP,nM);   
for k = 1:length(idxFamPhase)
    if ~isnan(idxFamPhase(k,1))         %% Check in case there was a lack in IMU recording and therefore no pos data is available
       nSTot(idxFamPhase(k,1),idxFamPhase(k,2)) = nSTot(idxFamPhase(k,1),idxFamPhase(k,2)) + 1;
    end
end

% Number of samples that are going to be added for training
nSAdd_preProc = zeros(nP,nM);  
idxNoAdaptAvailable = [];

% Initialization for P
nSAdd_postProc = zeros(nP,nM);
if ~exist('nSMajVote', 'var')
    nSMajVote = 1;  % if no MajVote defined -> then no processing by only looking at one sample
end

if ~isempty(idxAdapt)
    
    for j = 1:size(idxAdapt,1)
        
        ind{j,1} = find(ismember(idxFamPhase,idxAdapt(j,:),'rows'));
        ind_majVote = [];       % initialize for each position/hand motion
        
        % ###### Apply Majority Vote
        for k = 1:length(ind{j,1})
            desired = idxAdapt(j,2);
            indTemp = ind{j,1}(k);
            if indTemp >= nSMajVote;
                % Get previous predicted positions for majority vote,
                % second index "2" for position
                sequence = idxFamPhase(indTemp-nSMajVote+1:indTemp,2);
                majVote = mode(sequence);
                if majVote == desired
                    ind_majVote = [ind_majVote; indTemp];
                end       
            else
                %do nothing
            end    
        end
        
        ind_postProc{j,1} = ind_majVote;                                % Save indices of Majority Vote

%         if length(ind{j}) >= addThreshold
%         end
        nSAdd_preProc(idxAdapt(j,1), idxAdapt(j,2)) = length(ind{j});
        nSAdd_postProc(idxAdapt(j,1), idxAdapt(j,2)) = length(ind_postProc{j});
        
        if isfield(handles.fam, 'tacTest') 
            % Feature segments need to be transformed
            
            seg_temp = trSegFam(:,:,ind_postProc{j}); % Temporary segments
            imu_temp = imuSetsAug(:,:,ind_postProc{j});
            trFeatFam = [];
            
            for ii=1:size(seg_temp, 3)
                trFeatFam(ii,:) = SignalProcessing_RealtimePatRec(seg_temp(:,:,ii), patRecCal, imu_temp(:,:,ii));
            end
            
            if ~isempty(trFeatFam)
                 trFeatFam_Sel = [trFeatFam_Sel; trFeatFam];       % Selected feature vector
            else
                 disp(strcat('### NO DATA ADAPTATION  for Pos ', num2str(idxAdapt(j,1)), ' mov ', num2str(idxAdapt(j,2)), '! ###'));
            end
        
            
        % if features are already provided
        else 
            
             if ~isempty(trFeatFam)
                 trFeatFam_Sel = [trFeatFam_Sel; trFeatFam(ind_postProc{j},:)];       % Selected feature vector
             else
                 disp(strcat('### NO DATA ADAPTATION  for Pos ', num2str(idxAdapt(j,1)), ' mov ', num2str(idxAdapt(j,2)), '! ###'));
                 idxNoAdaptAvailable =  [idxNoAdaptAvailable, idxAdapt(j,:)];
             end
             
        end
        
        % Stack the Output vector of desired samples
        tempOut = outMov(ind_postProc{j});
        tempOutMask = zeros(length(tempOut),nM);
        for k = 1:length(tempOut) 
            tempOutMask(k, tempOut(k)) = 1; 
        end 
        trOutFam_Sel = [trOutFam_Sel; tempOutMask];                 % Selected out vector
    end
else
    disp('### NO DATA ADAPTATION (no underrepresented samples) ! ###')
end

% Check if any data has been added
if ~any(nSAdd_postProc, 'all')
    disp('### NO DATA ADAPTATION (no data for underrepresented samples available) ! ###')
end

nSAddAll = nSAdd_postProc';
nSAddAll(end+1,:) = sum(nSAddAll,1);

% Plot added features
f = figure;
title('Number of Added Samples');
imagesc(nSAddAll, [0 100]);
set(gca, 'XTick', 1:nP); set(gca, 'XTickLabel', 1:nP);
set(gca, 'YTick', 1:(nM+1)); set(gca, 'YTickLabel', [patRecCal.mov; 'All']);
% colormap winter;
colorbar;

%% Expand data set
trSetsAug = [trSets; trFeatFam_Sel];
trOutsAug = [trOuts; trOutFam_Sel];

    
%% Train patRec 

if strcmp(patRecCal.topology,'Single Classifier')
    %patRec.patRecTrained = OfflinePatRecTraining(alg, tType, trSets, trOuts, vSets, vOuts, trLables, vLables, movLables);
    patRecTrained_New = OfflinePatRecTraining(alg, tType, algConf, trSetsAug, trOutsAug, vSets, vOuts, patRecCal.mov, patRecCal.indMovIdx);
else
    disp('Augmentation only developed for single classifier')
end

%% Test performance

patRecNew = patRecCal;
patRecNew.patRecTrained =  patRecTrained_New;

[performance_New, ~, ~] = Accuracy_patRec(patRecNew, tSets, tOuts, 0, 0);
    
%% Save data
patRec = patRecCal;

patRec.patRecAug.patRecTrained_Old = patRecCal.patRecTrained;
patRec.patRecAug.performance_Old = patRecCal.performance;
patRec.patRecAug.patRecTrained_New= patRecTrained_New;
patRec.patRecAug.performance_New = performance_New;

patRec.patRecAug.nSTot = nSTot;
patRec.patRecAug.nSAdd = nSAdd_preProc;
patRec.patRecAug.nSAdd_postProc = nSAdd_postProc;
patRec.patRecAug.nSAddAll = nSAddAll;
patRec.patRecAug.nSMajVote = nSMajVote;
patRec.patRecAug.idxNoAdaptAvailable = idxNoAdaptAvailable;
patRec.patRecAug.accThreshold = patRecCal.accThreshold;  %%%%%%%%%%%%%% Adjust!
    
end