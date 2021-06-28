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

function AdaptiveLearner_DefaultPipeline()

% path = uigetdir;
file = 'cal';
fileAdapt = 'fam';
path = 'C:\Users\spieker\LRZ Sync+Share\MasterThesis\20_Coding\DataSets\20_MyoMex_NoScale';
% [file, path] = uigetfile({'*.mat';'*.csv'});
load([path,'\',file]);
% set(button, 'String', 'Wait');
progress = waitbar(0,'PreProcessing');
drawnow;
handles ={};

    if isfield(recSession,'trdata')
        recSession = rmfield(recSession,'trdata');         
    end
    if isfield(recSession,'cTp')
        recSession = rmfield(recSession,'cTp');         
    end
    
    if isfield(recSession,'nCh')
        nCh = recSession.nCh;
        if length(recSession.nCh) == 1
            recSession.nCh = 1:recSession.nCh;
            nCh = recSession.nCh;
        end    
    else
        nCh = 1:length(recSession.tdata(1,:,1));
        recSession.nCh = nCh;
    end
    
    if isfield(recSession, 'imudata')
        recSession.multiModal = true;
    else 
        recSession.multiModal = false;
    end

%% Signal Treatment
% Use all movements
% use all channels
% no downsampling
% no noise adding
% no scaling
cTp = 1.0;

sigTreated = RemoveTransient_cTp(recSession, cTp);
sigTreated = AddRestAsMovement(sigTreated, recSession);
% no artifacts
sigTreated.multiModal = recSession.multiModal;

waitbar(0.2,progress);
nw = fix(sigTreated.cT * sigTreated.cTp * sigTreated.nR / 0.2);
trP = 0.75;
vP = 0.0;
tP = 0.20;

sigTreated.eCt      = sigTreated.cT*sigTreated.cTp;
overlap = 0.05;
tT = sigTreated.cT * sigTreated.cTp * sigTreated.nR;
tw = 0.2;
offset = ceil(tw/overlap);
nw = fix(tT / overlap) - offset;
trN = fix(trP * nw);
% vN = fix(vP * nw);
vN = 1;
tN = fix(tP * nw);
        while trN+vN+tN < nw
            tN = tN + 1;
        end
%Treat
sigTreated.trSets = trN;
sigTreated.vSets = vN;
sigTreated.tSets = tN;
sigTreated.nW = nw;
sigTreated.tW = tw;
sigTreated.wOverlap = overlap;
sigTreated.fFilter = 'None';                                                            % !!!!!!!!!!!!!!!!!!CHANGE???????????????????????????????????????????
sigTreated.sFilter = 'None';

sigTreated.twSegMethod = 'Overlapped Cons';
waitbar(0.4,progress,'Treating');

%PosEstimation

%% Split the data into the time windows

% no signal separation
% no imu processing

[trData, vData, tData] = GetData(sigTreated);    
if sigTreated.multiModal
    [trDataIMU, vDataIMU, tDataIMU] = GetDataIMU(sigTreated); 
    %Remove raw treated IMU data
    sigTreated = rmfield(sigTreated,'trDataIMU');
%     disp('IMU Data included.')
end
%Remove raw trated data
sigTreated = rmfield(sigTreated,'trData');    
% Apply filters
[trData, vData, tData] = ApplyFiltersEpochs(sigTreated, trData, vData, tData);

% add the new sets of tw for tr, v and t
sigTreated.trData = trData;
sigTreated.vData = vData;
sigTreated.tData = tData;

if sigTreated.multiModal
    sigTreated.trDataIMU = trDataIMU;
    sigTreated.vDataIMU = vDataIMU;
    sigTreated.tDataIMU = tDataIMU;
end

%sigFeatures = GetAllSigFeatures(handles, sigTreated);
sigFeatures.sF      = sigTreated.sF;
sigFeatures.tW      = sigTreated.tW;
sigFeatures.nCh     = sigTreated.nCh;
sigFeatures.mov     = sigTreated.mov;
sigFeatures.fID = LoadFeaturesIDs('featuresIMU.def');
sigFeatures.wOverlap = sigTreated.wOverlap;
sigFeatures.tW      = sigTreated.tW;

% temporal conditional to keep compatibility with olrder rec session
if isfield(sigTreated,'dev')
    sigFeatures.dev     = sigTreated.dev;
else
    sigFeatures.dev     = 'Unknow';
end 

if isfield(sigTreated,'comm')
    sigFeatures.comm    = sigTreated.comm;
    if strcmp(sigFeatures.comm, 'COM')
        if isfield(sigTreated,'comn')
            sigFeatures.comn    = sigTreated.comn;
        end
    end
else
    sigFeatures.comm     = 'N/A';
end   

sigFeatures.fFilter = sigTreated.fFilter;
sigFeatures.sFilter = sigTreated.sFilter;
sigFeatures.trSets  = sigTreated.trSets;
sigFeatures.vSets   = sigTreated.vSets;
sigFeatures.tSets   = sigTreated.tSets;


waitbar(0.5,progress,'Treating');
nM = sigTreated.nM;          % Number of exercises

for m = 1: nM
    for i = 1 : sigTreated.trSets
        trFeatures(i,m) = GetSigFeatures(sigTreated.trData(:,:,m,i),sigTreated.sF, sigFeatures.fFilter, sigFeatures.fID , sigTreated.trDataIMU(:,:,m,i));
    end
end
waitbar(0.6,progress,'Treating');
for m = 1: nM
    for i = 1 : sigTreated.vSets
        vFeatures(i,m) = GetSigFeatures(sigTreated.vData(:,:,m,i),sigTreated.sF, sigFeatures.fFilter, sigFeatures.fID , sigTreated.vDataIMU(:,:,m,i));
    end
end
waitbar(0.7,progress,'Treating');
for m = 1: nM
    for i = 1 : sigTreated.tSets
        %tFeatures(i,m) = analyze_signal(sigTreated.tData(:,:,m,i),sigTreated.sF);
        tFeatures(i,m) = GetSigFeatures(sigTreated.tData(:,:,m,i),sigTreated.sF, sigFeatures.fFilter, sigFeatures.fID , sigTreated.tDataIMU(:,:,m,i));
    end
end
waitbar(0.75,progress,'Treating');
sigFeatures.trFeatures = trFeatures;    
sigFeatures.vFeatures  = vFeatures;    
sigFeatures.tFeatures  = tFeatures;

% Position estomation
posDef = '3 Positions';
sigFeatures = EstimatePosition(posDef, sigFeatures);
     

%% Offline PatRec (Top4+tcard, LDA, OvsO)
%%sigFeatures = get(handles.t_sigFeatures,'UserData');
sigFeatures.eTrSets = trN;
sigFeatures.eVSets = vN;
sigFeatures.eTSets = tN; 
%?No-norm set?
%?No-feature reduction?
waitbar(0.85,progress,'Training');


movMix = 'Individual Mov';
randFeatures = true;
confMatFlag = false;
posPerfFlag = true;
alg = 'Discriminant A.';
tType = 'linear';
topology = 'Single Classifier';                             % !!!!!!!!!!!!!!!!!!CHANGE???????????????????????????????????????????
selFeatures = {'tmabs';'twl';'tzc';'tslpch2'};
normSets = 'Select Normalization';
algConf = [];
featReducAlg = 'Select Reduc./Selec.';
%Adaptive Learning parameters
sigFeatures.accThreshold = 75;
%% Train model for defined repetitions
nRep = 3;
kFoldStat.kFold = nRep;
kFoldStat.pTrain = trP; kFoldStat.nTrain = trN;
kFoldStat.pVal = vP; kFoldStat.nVal = vN;
kFoldStat.pTest = tP; kFoldStat.nTest = tN;

% Init variables
kFoldStat.accCS       = zeros(nRep,nM+1);
kFoldStat.accTrue     = zeros(nRep,nM+1);
kFoldStat.precision   = zeros(nRep,nM+1);
kFoldStat.recall      = zeros(nRep,nM+1);
kFoldStat.f1          = zeros(nRep,nM+1);
kFoldStat.specificity = zeros(nRep,nM+1);
kFoldStat.npv         = zeros(nRep,nM+1);
kFoldStat.trTime = zeros(1,nRep);
kFoldStat.tTime = zeros(1,nRep);   

tAcc = 0;       % Initialize as zero to compare best performance in loop
tStd = inf;     % Required if deviation of class results is important as well
    
for i = 1 : nRep

    patRec = OfflinePatRec(sigFeatures, selFeatures, randFeatures, normSets, alg, tType, algConf, movMix, topology, confMatFlag, featReducAlg, posPerfFlag);
    tempPerformance = patRec.performance;

    kFoldStat.accCS(i,:)      = tempPerformance.acc;
    kFoldStat.accTrue(i,:)    = tempPerformance.accTrue;
    kFoldStat.precision(i,:)  = tempPerformance.precision;
    kFoldStat.recall(i,:)     = tempPerformance.recall;
    kFoldStat.f1(i,:)         = tempPerformance.f1;
    kFoldStat.specificity(i,:)= tempPerformance.specificity;
    kFoldStat.npv(i,:)        = tempPerformance.npv;   
    kFoldStat.trTime(i)       = patRec.trTime;
    kFoldStat.tTime(i)        = patRec.tTime;
    
    % Save the best patRec
%   if std(tempAcc(1:end-1)) <= tStd && tempAcc(end) >= tAcc
    if tempPerformance.acc(end) >= tAcc
%            tStd = std(tempAcc(1:end-1));
        tAcc = tempPerformance.acc(end);
        bestPatRec = patRec;
        kFoldStat.bestTrial = i;
    end
    
end

% patRec = OfflinePatRec(sigFeatures, selFeatures, randFeatures, normSets, alg, tType, algConf, movMix, topology, confMatFlag, featReducAlg, posPerfFlag);
handles.patRec = bestPatRec;

%% Augment
load([path,'\',fileAdapt]);
tDataFam = cdata;
imuDataFam = idata(:,1:4);   
addThreshold = 1;
[patRec, handles] = AugmentPatRec(tDataFam, imuDataFam, handles, alg, addThreshold);


handles.patRec = patRec; % Update

save([path, '\', file, '_patRec'], 'patRec', 'kFoldStat');


Load_patRec(handles.patRec, 'GUI_TestPatRec_Mov2Mov',1);
% set(button, 'String', 'Train Individual Mov)');
waitbar(1,progress,'Training');
close(progress);

% movMix = 'Mixed Output';
% randFeatures = true;
% confMatFlag = false; 
% alg = 'MLP';
% tType = 'Backpropagation';
% topology = 'Ago-antagonistAndMixed';
% selFeatures = {'tmabs';'twl';'tzc';'tslpch2';'tcard'};
% normSets = 'Midrange0Range2';
% algConf = [];
% featReducAlg = 'Select Reduc./Selec.';
% patRec = OfflinePatRec(sigFeatures, selFeatures, randFeatures, normSets, alg, tType, algConf, movMix, topology, confMatFlag, featReducAlg);
% handles.patRec = patRec;
% Load_patRec(handles.patRec, 'GUI_TestPatRec_Mov2Mov',1);
% set(button, 'String', 'Train Simultaneous Mov'); 
% waitbar(1,progress,'Training');
% close(progress);
end
