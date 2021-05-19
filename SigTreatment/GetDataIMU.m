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
% This function is a copy of the original function "GetData" 
% Instead of splitting the EMG signals into matrices of training, validation 
% and testing data it splits the acquired IMU data
% It will also send the data to the routine to break down its
% characteristics
%
% input:   Data is a Nsamples x Ndimension x Nexercises matrix    
%          sigTreated struct with the information required for the data
%          treatment
% output:  trdataIMU are the split training data from the original recording time 
%          vdataIMU are the split validation data
%          tdataIMU are the split testing data
%
% NOTE: Optimization could be implemented
%
% ------------------------- Updates & Contributors ------------------------
% [Contributors are welcome to add their email]
% 20xx-xx-xx / Max Ortiz  / Creation of GetData
% 2021-05-19 / Veronika Spieker / Adjustment for Myo IMU data

function [trdataIMU, vdataIMU, tdataIMU] = GetDataIMU (sigTreated)

    data = sigTreated.trDataIMU;            % trData only contains information from the contraction
    nM   = length(data(1,1,:));          % Number of movements

    % Some validations    
    ssize   = fix(length(data(:,1,1))/sigTreated.nR);     % Samples Size of a repetition or Number of samples that makes a repetition
    eCt     = sigTreated.eCt;                             % Due to several issues with matlab this was separated
    eCtc    = ssize/sigTreated.sF;                        % to more lines of code
    
    %if eCtc ~= eCt
    if abs(eCtc - eCt) > 0.0000001  % a tolerance had to be introduce due to matlab doubles inacuracy
        disp('ERROR!!!! No match between samples and eCt');
        errordlg('No match between samples and eCt','Error');
        return;
    end
    
    if sigTreated.trSets + sigTreated.vSets + sigTreated.tSets ~= sigTreated.nW                      % Verification
        disp('ERROR!!!! No match in total number of sets');
        errordlg('No match in total number of sets','Error');
        return;
    end    
    
    % Get Data
    if strcmp(sigTreated.twSegMethod,'Non Overlapped')

        nTw     = sigTreated.eCt/sigTreated.tW;             % Number of time windows per eCt
        if fix(nTw*sigTreated.nR) ~= sigTreated.nW                      % Verification
            disp('ERROR!!!! No match between number of time windows');
            errordlg('No match between number of time windows','Error');
            return;
        end

        assize  = fix(ssize /nTw);              % Absolute number of samples that corresponde to the window time of a repetition

        for e = 1: nM
            for i = 1 : sigTreated.nW
                iidx = 1 + (assize*(i-1));
                eidx = assize+(assize*(i-1));
                %tempdata(i,e) = analyze_signal(data(iidx:eidx,:,e),sigTreated.sF);
                tempdata(:,:,e,i) = data(iidx:eidx,:,e);
            end
        end

    elseif strcmp(sigTreated.twSegMethod,'Overlapped Cons')
        
        tWsamples = sigTreated.tW * sigTreated.sF;              % Samples corresponding Time window
        oS = sigTreated.wOverlap * sigTreated.sF;   % Samples correcponding overlap

        for e = 1: nM
            for i = 1 : sigTreated.nW
                iidx = 1 + (oS * (i-1));
                eidx = tWsamples + (oS *(i-1));
                tempdata(:,:,e,i) = data(iidx:eidx,:,e);
            end
        end



    elseif strcmp(sigTreated.twSegMethod,'Overlapped Rand')

    end
    
    
    trSets  = sigTreated.trSets;
    vSets   = sigTreated.vSets;
    tSets   = sigTreated.tSets;
    trdataIMU  = tempdata(:,:,:,1:trSets);
    vdataIMU   = tempdata(:,:,:,trSets+1:trSets+vSets);
    tdataIMU   = tempdata(:,:,:,trSets+vSets+1:trSets+vSets+tSets);

    
end