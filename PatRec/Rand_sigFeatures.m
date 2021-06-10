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
% Function to randomize the order of the validation data
%
% ------------------------- Updates & Contributors ------------------------
% [Contributors are welcome to add their email]
% 20xx-xx-xx / Max Ortiz  / Creation
% 2009-07-21 / Max Ortiz  / Change to use the treated_data struct
% 2011-06-23 / Max Ortiz / New names and coding standard
% 2011-07-19 / Max Ortiz / New names and coding standard to new struct
%                       sigFeatures
% 2021-06-10 / Veronika Spieker / Added randomization of positional
%                               classifiers to keep consistent pairs

function sigFeatures  = Rand_sigFeatures(sigFeatures)

if isfield(sigFeatures, 'pos')
    
    temp(1:sigFeatures.trSets,:) = sigFeatures.trFeatures;
    temp(sigFeatures.trSets + 1 : sigFeatures.trSets + sigFeatures.vSets,:) = sigFeatures.vFeatures;
    temp(sigFeatures.trSets + sigFeatures.vSets + 1 : sigFeatures.trSets + sigFeatures.vSets + sigFeatures.tSets,:) = sigFeatures.tFeatures;

    temp_p(1:sigFeatures.trSets,:) = sigFeatures.trPos;
    temp_p(sigFeatures.trSets + 1 : sigFeatures.trSets + sigFeatures.vSets,:) = sigFeatures.vPos;
    temp_p(sigFeatures.trSets + sigFeatures.vSets + 1 : sigFeatures.trSets + sigFeatures.vSets + sigFeatures.tSets,:) = sigFeatures.tPos;

    temp2 = temp;
    temp2_p = temp_p;

    for i = 1 : size(temp,1)
        j = round(1 + rand * (size(temp,1)-1));
        all(i) = j;
        temp(i,:) = temp2(j,:); temp(j,:) = temp2(i,:);          % Ramdomly switches samples
        temp_p(i,:) = temp2_p(j,:); temp_p(j,:) = temp2_p(i,:);  % Shuffling position data in same manner
        temp2 = temp; temp2_p = temp_p;
    end

    sigFeatures.trFeatures = temp(1:sigFeatures.trSets,:);
    sigFeatures.vFeatures  = temp(sigFeatures.trSets+1:sigFeatures.trSets+sigFeatures.vSets,:);
    sigFeatures.tFeatures  = temp(sigFeatures.trSets+sigFeatures.vSets+1:sigFeatures.trSets+sigFeatures.vSets+sigFeatures.tSets,:);

    sigFeatures.trPos = temp_p(1:sigFeatures.trSets,:);
    sigFeatures.vPos = temp_p(sigFeatures.trSets+1:sigFeatures.trSets+sigFeatures.vSets,:);
    sigFeatures.tPos  = temp_p(sigFeatures.trSets+sigFeatures.vSets+1:sigFeatures.trSets+sigFeatures.vSets+sigFeatures.tSets,:);

else 
    
    temp(1:sigFeatures.trSets,:) = sigFeatures.trFeatures;
    temp(sigFeatures.trSets + 1 : sigFeatures.trSets + sigFeatures.vSets,:) = sigFeatures.vFeatures;
    temp(sigFeatures.trSets + sigFeatures.vSets + 1 : sigFeatures.trSets + sigFeatures.vSets + sigFeatures.tSets,:) = sigFeatures.tFeatures;

    temp2 = temp;

    for i = 1 : size(temp,1)
        j = round(1 + rand * (size(temp,1)-1));
        temp(i,:) = temp2(j,:); 
        temp(j,:) = temp2(i,:);
        temp2 = temp;
    end

    sigFeatures.trFeatures = temp(1:sigFeatures.trSets,:);
    sigFeatures.vFeatures  = temp(sigFeatures.trSets+1:sigFeatures.trSets+sigFeatures.vSets,:);
    sigFeatures.tFeatures  = temp(sigFeatures.trSets+sigFeatures.vSets+1:sigFeatures.trSets+sigFeatures.vSets+sigFeatures.tSets,:);
    
end


