% ---------------------------- Copyright Notice ---------------------------
% This file is part of BioPatRec � which is open and free software under 
% the GNU Lesser General Public License (LGPL). See the file "LICENSE" for 
% the full license governing this code and copyrights.
%
% BioPatRec was initially developed by Max J. Ortiz C. at Integrum AB and 
% Chalmers University of Technology. All authors� contributions must be kept
% acknowledged below in the section "Updates % Contributors". 
%
% Would you like to contribute to science and sum efforts to improve 
% amputees� quality of life? Join this project! or, send your comments to:
% maxo@chalmers.se.
%
% The entire copyright notice must be kept in this or any source file 
% linked to BioPatRec. This will ensure communication with all authors and
% acknowledge contributions here and in the project web page (optional).
%
% ------------- Function Description -------------
% This function will create matrices of training, validation and test sets
% - All movements will be STACK one over each other, this is, each set of
% movements will be the row and the colums are made of the features.
% - The number of columbs is given by the nuber of channels times the
% features
% - The value of the first features in each channel is then follow for the
% value of the second features in each channel and so on. 
%
% NOTE: The main difference with GetSets_Stack is that the mixed movements 
% are only considered in the testing set
%
% input:   trFeatures contains the splitted data, is a Nsplits x Nexercises structure matrix
%          vFeatures is similar to trFeatures 
%          features contains the name of the charactaristics to be used
% output:  trsets are the normalized training sets
%          vsets are the normalized validation sets
%          trOut contains the correspondet outputs
%          vOut contains the correspondet outputs
%
% ------------- Updates -------------
%  2011-10-03 / Max Ortiz / Created
% 2021-06-11 / Veronika Spieker  / Adjust stacking of data if an unequal group size is used for training
% 20xx-xx-xx / Author  / Comment on update

function [trSet, trOut, vSet, vOut, tSet, tOut, movIdx, movOutIdx] = GetSets_Stack_IndvMov(sigFeatures, features)

%Variables
movIdx    = [];
movIdxMix = [];

% Find the mixed movements by looking for "+"
% use of a temporal index to match the output, this assumes that the order
% of the output is the same as the order of the movements 
tempIdx = 1;
for i = 1 : size(sigFeatures.mov,1)
    if isempty(strfind(sigFeatures.mov{i},'+'))
        movIdx = [movIdx i];
        movOutIdx{i} = tempIdx;  % Index for the output of each movement
        tempIdx = tempIdx + 1;
    else
        movIdxMix = [movIdxMix i];
    end
end

nMi   = size(movIdx,2);           % Number of movements individuals
nMm   = size(movIdxMix,2);        % Number of movements mixed

trSets = sigFeatures.eTrSets;     % effective number of sets for trainning

% Testing of adding single hand motions and more features
% Additional feature for one movement leads to empty struct for others
% sigFeatures.trFeatures(end+1,1) = sigFeatures.vFeatures(1,1);
% sigFeatures.trFeatures(end+1,:) = sigFeatures.vFeatures(end,:);
% trSets = sigFeatures.trSets+2;

if isempty(sigFeatures.vFeatures)
    vSets = 0;
else
    vSets  = sigFeatures.eVSets;      % Number of sets for valdiation
end

if isempty(sigFeatures.tFeatures)
    tSets = 0;
else
    tSets  = sigFeatures.eTSets;      % Number of sets for testing
end

Ntrset = trSets * nMi;
Nvset  = vSets  * nMi;
Ntset  = tSets  * nMi;

trSet = zeros(Ntrset, length(features));
vSet  = zeros(Nvset , length(features));
tSet  = zeros(Ntset , length(features));

trOut = zeros(Ntrset, nMi);
vOut  = zeros(Nvset , nMi);
tOut  = zeros(Ntset , nMi);

% Stack data sets for individual movements

for j = 1 : nMi;
    e = movIdx(j);
    % Training
    for r = 1 : trSets
        sidx = r + (trSets*(j-1));
        li = 1;
        for i = 1 : length(features)
            le = li - 1 + length(sigFeatures.trFeatures(r,e).(features{i}));
            trSet(sidx,li:le) = sigFeatures.trFeatures(r,e).(features{i}); % Get each feature per channel
            li = le + 1;
        end
        trOut(sidx,j) = 1;
    end
    % Validation
    for r = 1 : vSets
        sidx = r + (vSets*(j-1));
        li = 1;
        for i = 1 : length(features)
            le = li - 1 + length(sigFeatures.vFeatures(r,e).(features{i}));
            vSet(sidx,li:le) = sigFeatures.vFeatures(r,e).(features{i});
            li = le + 1;
        end
        vOut(sidx,j) = 1;
    end
    % Test
    for r = 1 : tSets
        sidx = r + (tSets*(e-1));   % Use e instead of j for test
        li = 1;
        for i = 1 : length(features)
            le = li - 1 + length(sigFeatures.tFeatures(r,e).(features{i}));
            tSet(sidx,li:le) = sigFeatures.tFeatures(r,e).(features{i});
            li = le + 1;
        end
        tOut(sidx,j) = 1;
    end
end

% Extract information for mixed patterns
for j = 1 : nMm;    
    e = movIdxMix(j);    % index of the movement
    %find mixed movements
    for i = 1 : nMi
        ii = movIdx(i);
        if isempty(strfind(sigFeatures.mov{e},sigFeatures.mov{ii}))
            idxMix(i) = 0;
        else
            idxMix(i) = 1;            
        end
    end
    
    % Test
    for r = 1 : tSets
        sidx = r + (tSets*(e-1));
        li = 1;
        for i = 1 : length(features)
            le = li - 1 + length(sigFeatures.tFeatures(r,e).(features{i}));
            tSet(sidx,li:le) = sigFeatures.tFeatures(r,e).(features{i});
            li = le + 1;
        end
        tOut(sidx,:) = idxMix;
    end

    movOutIdx{e} = find(idxMix);
        
end

 %% Stack pos data as well
 % How can uneven data amount be handled? Simply adding at the end?
bEmptySamples = all(trSet == 0, 2);
idxEmptySamples = find(bEmptySamples == 1);
for i = 1:length(idxEmptySamples)
 idxNew = idxEmptySamples(i)-i+1;
 trSet(idxNew,:) = [];
 trOut(idxNew,:) = [];
end



