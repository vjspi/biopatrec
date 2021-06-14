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
% Process information of position specific performance

% idxAdapt: indicates in what position (1st column) what hand motion (2nd
%           motion) is still inaccurate
%
% ------------------------- Updates & Contributors ------------------------
% [Contributors are welcome to add their email]
% 2021-06-14 / Veronika Spieker

function [accPos, idxAdapt] = PositionPerformance_Analysis(patRec, performancePos, confMatAll, confMatPos, confMatFlag)

accThreshold = 75;      % Threshold for position that needs to be adapted

nM      = size(patRec.mov,1);     
pos = patRec.pos.idx;
nPos = size(pos,2);
accPos = zeros(nM+1, nPos); 

%% Plot confusion matrices
if confMatFlag
    % Plot position dependent confusion matrices
    figure;
    tlo = tiledlayout(2,2);
    for p = 1:length(performancePos)
        h(p) = nexttile(tlo);
        confMatPos{p}(isnan(confMatPos{p}))=0;  % Replace NaN values (due to division by zero if hand motion not present in one position)

        imagesc(confMatPos{p});
        title(['Position ', num2str(p)])
        xlabel('Movements'); ylabel('Movements');
        set(h, 'CLim', [0 1]);
        colorbar;
    end
    h(p+1) = nexttile(tlo);
    imagesc(confMatAll); 
    title('All Positions');
    set(h, 'CLim', [0 1]);
    colorbar;
end
       
%% Analyze accuracy
% Restructure position dependent accuracy
for p = 1:length(performancePos)
    accPos(:,p) = performancePos{p}.acc;
end

f = figure;
imagesc(accPos, [50 100]);
set(gca, 'XTick', 1:nPos); set(gca, 'XTickLabel', pos);
set(gca, 'YTick', 1:(nM+1)); set(gca, 'YTickLabel', [patRec.mov; 'All']);
colorbar;
hold on;
[idxAdapt(:,2), idxAdapt(:,1)] = find(accPos < accThreshold);
plot(idxAdapt(:,1), idxAdapt(:,2), 'k*');

end
