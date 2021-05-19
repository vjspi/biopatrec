%% Function to extract labeled and preprocessed signals from BioPatRec
% Assumptions:
%   - no mixed movements
%   - no splitting
%   - all desired information in one folder

function ConvertFeatureSet()

%% Predefined features
features =  {'tmabs';'twl';'tzc';'tslpch2'};
featuresIMU = {'tmn'}

% path=uigetdir();
path = "C:\Users\spieker\LRZ Sync+Share\MasterThesis\20_Coding\DataSets\Trial6_4mov_left_MyoMex_IMUinterp_dynamicT\Treated";
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
        
        % Extracting mean of IMU data
        for m = 1: nM
            for i = 1 : trSets
                trFeaturesIMU(i,m) = GetSigFeatures(sigFeatures.trDataIMU(:,:,m,i),sigFeatures.sF,sigFeatures.fFilter, featuresIMU);
            end
        end
        for m = 1: nM
            for i = 1 : vSets
                vFeaturesIMU(i,m) = GetSigFeatures(sigFeatures.vDataIMU(:,:,m,i),sigFeatures.sF,sigFeatures.fFilter, featuresIMU);
            end
        end
        for m = 1: nM
            for i = 1 : tSets
                tFeaturesIMU(i,m) = GetSigFeatures(sigFeatures.tDataIMU(:,:,m,i),sigFeatures.sF,sigFeatures.fFilter, featuresIMU);
            end
        end
        
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
                %Adding IMU data conversion
                li = 1; 
                for j = 1 : length(featuresIMU)
                    le = li - 1 + length(trFeaturesIMU(r,e).(featuresIMU{j}));
                    trSetIMU(sidx,li:le) = trFeaturesIMU(r,e).(featuresIMU{j});
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
                %Adding IMU data conversion
                li = 1; 
                for j = 1 : length(featuresIMU)
                    le = li - 1 + length(vFeaturesIMU(r,e).(featuresIMU{j}));
                    vSetIMU(sidx,li:le) = vFeaturesIMU(r,e).(featuresIMU{j});
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
                %Adding IMU data conversion
                li = 1; 
                for j = 1 : length(featuresIMU)
                    le = li - 1 + length(tFeaturesIMU(r,e).(featuresIMU{j}));
                    tSetIMU(sidx,li:le) = tFeaturesIMU(r,e).(featuresIMU{j});
                    li = le + 1;
                end
                tOut(sidx,e) = 1;
            end
        end
              
        
        %% Normalize the data set??
        
        %% Create feature vector
        X = array2table([[trSet; vSet; tSet], [trSetIMU; vSetIMU; tSetIMU]]);
        
        %Naming the columns
        noFeat = length(features);
        noFeatIMU = length(featuresIMU);
        noChan = 8; noIMU= 4;   % Change!!!
        for i=1:noFeat;
            for j = 1:noChan;
                xTitle{j+(i-1)*noChan} = [features{i},num2str(j)];
            end
        end
        idx = length(xTitle)
        for k=1:noFeatIMU;
            for m = 1:noIMU;
                xTitle{idx + m + (k-1)*noIMU} = ['imu_', featuresIMU{k},num2str(m)];
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
