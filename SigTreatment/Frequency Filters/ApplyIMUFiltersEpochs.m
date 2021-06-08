% ---------------------------- Copyright Notice ---------------------------
% This file is part of BioPatRec ?? which is open and free software under 
% the GNU Lesser General Public License (LGPL). See the file "LICENSE" for 
% the full license governing this code and copyrights.
%
% BioPatRec was initially developed by Max J. Ortiz C. at Integrum AB and 
% Chalmers University of Technology. All authors??? contributions must be kept
% acknowledged below in the section "Updates % Contributors". 
%
% Would you like to contribute to science and sum efforts to improve 
% amputees??? quality of life? Join this project! or, send your comments to:
% maxo@chalmers.se.
%
% The entire copyright notice must be kept in this or any source file 
% linked to BioPatRec. This will ensure communication with all authors and
% acknowledge contributions here and in the project web page (optional).
%
% -------------------------- Function Description -------------------------
% Application of conventional filters.
%
% ------------------------- Updates & Contributors ------------------------
% [Contributors are welcome to add their email]
% 2016-03-07 / Julian Maier  / Creation
% 20xx-xx-xx / Author  / Comment on update

function [trDataImu, vDataImu, tDataImu] = ApplyIMUFiltersEpochs(sigTreated, trDataImu, vDataImu, tDataImu)

  dataImuAll = cat(4,trDataImu, vDataImu, tDataImu);
  sF = sigTreated.sF;

    for iNb = 1:size(dataImuAll,4)      % Number of sample windows
        for iMov = 1:sigTreated.nM
              if strcmp(sigTreated.imuProcessing, 'None')
                  % Do nothing and exit if
              elseif  strcmp(sigTreated.imuProcessing, '20 Hz LP')
                   dataImuAll(:,:,iMov,iNb) = FilterLP20hz(sF, dataImuAll(:,:,iMov,iNb));
              end
        end
    end
 [trDataImu, vDataImu ,tDataImu] = SplitCatData(dataImuAll,sigTreated);

end