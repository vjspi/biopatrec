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
% Funtion to execute a one shot position estimation for a single testing
% set. The position definition is here as previously defined
%
% OutPos    : Is the index of the recorded position(only one)
% 
% ------------------------- Updates & Contributors ------------------------
% 2021-06-08 / Veronika Spieker  / Creation
% 20xx-xx-xx / Author / Comment on update 

function [outPos] = OneShotPositionEstimation(pos,imuSet)

nPos = length(pos.idx);

imuEuler = quat2eul(imuSet); % XYZ rotation

if ~isnan(imuEuler(2))
    
    for iPos = 1:nPos
       if imuEuler(2) <= pos.range(iPos+1)
           outPos = iPos;
           break;
       else
           % Continue in loop to check for next position
       end
    end
    
else
    outPos = NaN;
end

   
%     
%     if strcmp(patRecTrained.algorithm,'MLP') || ...
%         strcmp(patRecTrained.algorithm,'MLP thOut')
%     
%         [outMov outVector] = MLPTest(patRecTrained, imuSet);
%                 
%     elseif strcmp(patRecTrained.algorithm,'DA')
% 
%         [outMov outVector] = DiscriminantTest(patRecTrained.coeff,imuSet,patRecTrained.training);        
%         
%     end
% 
%     % Validation to prevent outMov to be empty which cause problems on the
%     % GUI
%     if isempty(outMov)
%         outMov = 0;
%     end    
    
end