%% Function to extract labeled and preprocessed signals from BioPatRec
% Assumptions:
%   - no mixed movements
%   - no splitting
%   - all desired information in one folder

function ConvertFeatureSet()

%% Predefined features
features =  {'tmabs';'twl';'tzc';'tslpch2'};

% path=uigetdir();
path = "C:\Users\spieker\LRZ Sync+Share\MasterThesis\20_Coding\DataSets\Trial1_4_mov_right\Treated";
Files = dir(fullfile(path, '*.mat'));

%% Hardcoded ratio
% sigFeatures.eTrSets = 48;
% sigFeatures.eVSets = 24;
% sigFeatures.eTSets = 49;


%% Run through all files 

for ff = 1 : size(Files)
    
    if isfile(strcat(path, filesep, Files(ff).name))
        
        load(strcat(path, filesep, Files(ff).name), 'sigFeatures');
        
        trSets  = sigFeatures.trSets;
        vSets = sigFeatures.vSets;
        tSets  = sigFeatures.tSets;
                
        %% Part of function GetSets_Stack (copied)
        
        %% Get global data
        %Variables
        nM        = size(sigFeatures.mov,1);
        % nMm       = sum(cellfun(@(x) any(strfind(x,'+')), sigFeatures.mov));
        % nMi       = nM-nMm;
        movIdx    = 1:size(sigFeatures.mov,1);
        % movIdxMix = zeros(1,nMm);
        movOutIdx = cell(1,nM);

        Ntrset = trSets * nM;
        Nvset  = vSets  * nM;
        Ntset  = tSets  * nM;
        trSet = zeros(Ntrset, length(features));
        vSet  = zeros(Nvset , length(features));
        tSet  = zeros(Ntset , length(features));
        trOut = zeros(Ntrset, nM);
        vOut  = zeros(Nvset , nM);
        tOut  = zeros(Ntset , nM);

        for e = 1 : nM
            % Training
            for r = 1 : trSets
                sidx = r + (trSets*(e-1));
                li = 1;
                for i = 1 : length(features)
                    le = li - 1 + length(sigFeatures.trFeatures(r,e).(features{i}));
                    trSet(sidx,li:le) = sigFeatures.trFeatures(r,e).(features{i});
                    li = le + 1;
                end
                trOut(sidx,e) = 1;
            end
            % Validation
            for r = 1 : vSets
                sidx = r + (vSets*(e-1));
                li = 1;
                for i = 1 : length(features)
                    le = li - 1 + length(sigFeatures.vFeatures(r,e).(features{i}));
                    vSet(sidx,li:le) = sigFeatures.vFeatures(r,e).(features{i});
                    li = le + 1;
                end
                vOut(sidx,e) = 1;
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
                tOut(sidx,e) = 1;
            end
        end
              
        
        %% Normalize the data set??
        
        %% Create feature vector
        X = array2table([trSet; vSet; tSet]);
        
        %Naming the columns
        noFeat = length(features);
        noChan = width(X)/noFeat;
        for i=1:noFeat;
            for j = 1:noChan;
                xTitle{j+(i-1)*noChan} = [features{i},num2str(j)];
            end
        end
        X.Properties.VariableNames =  xTitle;
        
        writetable(X,strcat(path,'\X',erase(Files(ff).name, ".mat"),'.csv'));
        
        %% Create result vector
        
        % Result vector
        Y = array2table([trOut; vOut; tOut]);
        yName= sigFeatures.mov;
        
        for i=1:length(sigFeatures.mov)
            yTitle{i} = yName{i}(find(~isspace(yName{i})));
        end

        Y.Properties.VariableNames = yTitle;
        writetable(Y, strcat(path,'\Y',erase(Files(ff).name, ".mat"),'.csv'));
               
    end

end
