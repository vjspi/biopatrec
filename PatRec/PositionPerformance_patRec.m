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
%
% Compute the accuracy of the patRec algorithm for each position
%
% ------------------------- Updates & Contributors ------------------------
% [Contributors are welcome to add their email]
% 2021-06-15 / Veronika Spieker / Creation - Expands the Accuracy_patRec
% function

function [perfPos confMatPos tTimePos sMPos] = PositionPerformance_patRec(patRec, tSet, tOut, tPos, confMatFlag)

% Init variables
nM      = size(patRec.mov,1);       % Number of movements (total)
nOut    = size(tOut,2);             % Number of outputs

% sM      = size(tOut,1)/nM;          % Sets per movement
good    = zeros(size(tSet,1),1);    % Keep track of the good prediction

% confMat = zeros(nM,nOut+1);
% tTime   = zeros(1,size(tSet,1));
% % prediction metrics
% maskMat = zeros(size(tSet,1),nOut);
% FN      = zeros(size(tSet,1),nOut);
% TN      = zeros(size(tSet,1),nOut);
% TP      = zeros(size(tSet,1),nOut);
% FP      = zeros(size(tSet,1),nOut);

pos = patRec.pos.idx;
nPos = size(pos,2);

%Struct/Cells 
idxPos = cell(1, nPos); 
tSetPos = cell(1, nPos); 
tOutPos = cell(1, nPos);
perfPos = cell(1, nPos); 
confMatPos = cell(1, nPos); 

% Arrays
tTimePos = zeros(1, nPos);
sMPos = zeros(nM, nPos);
nSamplesPos = zeros(1, nPos);

for p = 1:nPos
    
    idxPos{p} = find(tPos == pos(p));
    nSamplesPos(p) = size(idxPos{p},1);
    
    tSetPos{p} = tSet(idxPos{p},:);
    tOutPos{p} = tOut(idxPos{p},:);
    
    [perf confMat tTime sM] = Accuracy_patRec(patRec, tSetPos{p}, tOutPos{p}, confMatFlag, 1); % posPerfFlag on (since this script only runs if Flag is true)
    perfPos{p} = perf;
    confMatPos{p} = confMat;
    tTimePos(p) = tTime;
    sMPos(:, p) = sM;
end

% Find underrepresented sample size and notify user
[row,col] = find(sMPos == 0);


for i=1:length(row)
    disp(['No motion "',patRec.mov{row(i)}, '" in position ', num2str(col(i))]);
end

% 
% for i = 1 : size(tSet,1)
%     % Start the timer for testing/prediction time
%     tStart = tic;
%     %Normalize set
%     x = NormalizeSet(tSet(i,:), patRec);
%     x = ApplyFeatureReduction(x, patRec);
%     %% Classification
%     [outMov outVector] = OneShotPatRecClassifier(patRec, x);    
%     tTime(i) = toc(tStart);
%     
%     %% Count the number of correct predictions
%     if ~isempty(outMov)
%         if outMov ~= 0
%             % Create a mask to match the correct output
%             mask = zeros(1,nOut);
%             mask(outMov) = 1;
%             % Save the mask for future computation of prediction metrics
%             maskMat(i,:)=mask;
%             % Are these the right movements?
%             if tOut(i,:) == mask    
%                 good(i) = 1;
%             else
%                 %stop for debuggin purposes
%             end
%             
%             outVec(i, :) = outVector;
%             
% %             %Evaluate a single movement only / not suitable for simult.
% %               if tOut(i,outMov) == 1      
% %                   good(i) = 1;
% %               end
% 
%         else
%             %If outMov = 0, then count it for the confusion matrix as no
%             %prediction in an additional output
%             outMov = nOut+1;
%         end
%     else
%         %If outMov = empty, then count it for the confusion matrix as no
%         %prediction in an additional output
%         outMov = nOut+1;
%     end
%     
%     %Confusion Matrix
%     if confMatFlag
%         expectedOutIdx = fix((i-1)/sM)+1;   % This will only work if there is an equal number of sets per class
%         confMat(expectedOutIdx,outMov) = confMat(expectedOutIdx,outMov) + 1;
%     end    
% end
% tTime = mean(tTime);
% 
% % Verify that dimension of maskMat and tOut match
% if size(tSet,1) ~= size(maskMat,1)
%     disp('error in maskMat');
% end
% if size(tSet,1) ~= size(tOut,1)
%     disp('error in tOut');    
% end
% % Compute the FP, FN, TP, TN using the saved maskMat
% for m=1:size(tSet,1)
%     for n=1:nOut
%         if tOut(m,n) == maskMat(m,n)
%             if tOut(m,n) == 1
%                 TP(m,n) = 1; 
%             else
%                 TN(m,n) = 1;
%             end
%         else
%             if tOut(m,n) == 1
%                 FN(m,n) = 1;
%             else
%                 FP(m,n) = 1;
%             end
%         end
%     end 
% end
% 
% % get total
% tPs=sum(sum(TP));    
% fPs=sum(sum(FP));
% tNs=sum(sum(TN));
% fNs=sum(sum(FN));
% 
% % Compute metrics per movement/class
% % This will only work if there are the same number of movements
% acc     = zeros(nM+1,1);
% tPvec   = zeros(nOut,nM);
% tNvec   = zeros(nOut,nM);
% fPvec   = zeros(nOut,nM);
% fNvec   = zeros(nOut,nM);
% 
% for i = 1 : nM
%     s = 1+((i-1)*sM);
%     e = sM*i;
%     acc(i) = sum(good(s:e))/sM;
%     tPvec(:,i)=sum(TP(s:e,:));
%     tNvec(:,i)=sum(TN(s:e,:));
%     fPvec(:,i)=sum(FP(s:e,:));
%     fNvec(:,i)=sum(FN(s:e,:));
% 
%     if tPvec(:,i) > sM
%         disp('Error on Ture Possitives');
%     end        
%     if tNvec(:,i) > size(tSet,1)-sM
%         disp('Error on Ture Negatives');
%     end    
%     
% end    
% acc(i+1) = sum(good) / size(tSet,1);
% tPvec = sum(tPvec)';
% tNvec = sum(tNvec)';
% fPvec = sum(fPvec')';  % transpose to sum the false positives in each predicted class (corresponds to each row, whereas ground truth is given by column)
% fNvec = sum(fNvec)';
% 
% %Compute the precision per movement
% precision = tPvec ./(tPvec+fPvec);
% precision(end+1) = tPs/(tPs+fPs);
% 
% %Compute the recall per movement
% recall = tPvec ./(tPvec+fNvec);
% recall(end+1) = tPs/(tPs+fNs);
% 
% %Compute the specificity per movement
% specificity=tNvec ./(tNvec+fPvec);
% specificity(end+1)=tNs/(tNs+fPs);
% 
% %Compute the npv per movement
% npv=tNvec ./(tNvec+fNvec);
% npv(end+1)=tNs/(tNs+fNs);
% 
% %Compute the f1 per movement
% f1=(2.*precision.*recall)./(precision+recall);
% 
% % True accuracy / global accuracy
% accTrue=(tPvec+tNvec)./(tPvec+fPvec+fNvec+tNvec);
% accTrue(end+1)=(tPs+tNs)/(tNs+tPs+fPs+fNs);
% 
% % Save performance metrics
% performance.acc = acc*100;
% performance.accTrue = accTrue*100;
% performance.precision = precision*100;
% performance.recall = recall*100;    % Sensitivity
% performance.f1 = f1;
% performance.specificity= specificity*100;
% performance.npv = npv*100;
% 
% % Print confusion matrix
% if confMatFlag
%     confMat = confMat ./ sM; % This will only work if there is an equal number of sets per class
%     figure;
%     imagesc(confMat);
%     title('Confusion Matrix')
%     xlabel('Movements');
%     ylabel('Movements');
% end
