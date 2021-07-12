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
% Estimation of limb position based on orientation data recorded by the IMU
%
% ------------------------- Updates & Contributors ------------------------
% [Contributors are welcome to add their email]
% 2021-06-08 / Veronika Spieker  / Creation
% 20xx-xx-xx / Author  / Comment on update

% function [trDataPos, vDataPos, tDataPos] = EstimatePosition(sigTreated, trDataImu, vDataImu, tDataImu)
function sigFeatures = EstimatePosition(posDef, sigFeatures)


  if strcmp(posDef, '3 Positions')
      % identification of positions based on y orientation in Euler Angles
      % Reference position for Myo orientation:
      % Lower arm extended to the front straight with Myo Logo facing up
      % (either 90 deg shoulder or elbow flexion)
      
      % From this position (roughly):
      % x axis: Intersection of coronal and sagittal plane
      %         (abduction/adduction)
      % y axis: Intersection of transverse and coronal plane 
      %         (elbow or shoulder flexion)
      % z axis: Intersection of transverse and sagittal plane 
      %         (pronation/supination) 
      
      % euler angles range from -pi to pi
      % pos1 = [-pi, -1/3*pi]; pos2 = [-1/3*pi, 1/3* pi]; pos3 = [1/3*pi, pi];
      
      nPos = 3;      
      pos.idx = 1:nPos;
      pos.range = linspace(-pi/2,pi/2,nPos+1); % areas of positions
      pos.label = {['S_0deg & E_0Deg'] ['E_90deg or S_90deg'] ['S_135deg or E_135deg']};

  end
    
  
  %% Initialization
  allFeatures = cat(1,sigFeatures.trFeatures, sigFeatures.vFeatures, sigFeatures.tFeatures);
  nSmp = size(allFeatures,1);
  nM =  size(allFeatures,2);
  allPosEuler = zeros(nSmp, nM, 3);
  allPosIndex = zeros(nSmp, nM);
  
  %% Computation of each position

    for iNb = 1:nSmp      % Number of samples
        for iMov = 1:nM
            %Quaternions
            allPosQuat(iNb, iMov, :) = allFeatures(iNb, iMov).itmn_quat;
            % Euler
            allPosEuler(iNb, iMov, :) = quat2eul(allFeatures(iNb, iMov).itmn_quat, 'ZYX'); % XYZ rotation
            
            % Taking y orientation
            for iPos = 1:nPos
               if allPosEuler(iNb, iMov, 2) <= pos.range(iPos+1)
                   allPosIndex(iNb, iMov) = iPos;
                   break;
               else
                   % Continue in loop to check for next position
               end
            end
   
        end
    end

    
    sigFeatures.pos = pos;
    
    sigFeatures.trPos = allPosIndex(1:sigFeatures.trSets, :);
    sigFeatures.vPos = allPosIndex(sigFeatures.trSets+1:sigFeatures.trSets+sigFeatures.vSets, :);
    sigFeatures.tPos = allPosIndex(sigFeatures.trSets+sigFeatures.vSets+1:end, :);
    
    sigFeatures.trQuat= allPosQuat(1:sigFeatures.trSets, :, :);
    
    
    %% Plot for testing
    f = figure;
    hold on;
    for iMov=1:nM
        plot(allPosEuler(:,iMov,2), 'DisplayName', num2str(iMov));
    end
    % Boundaries
    yline(sigFeatures.pos.range(2), 'r--',  'DisplayName', 'Boundary Pos 1 & 2');
    yline(sigFeatures.pos.range(3), 'r--', 'DisplayName', 'Boundary Pos 2 & 3');
    legend;
    hold off;

end