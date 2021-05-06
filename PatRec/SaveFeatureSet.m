function SaveFeatureSet(selFeatures, trSets, vSets, tSets, movLables, trOuts, vOuts, tOuts, path)

path = 'C:\Users\spieker\LRZ Sync+Share\MasterThesis\20_Coding\DataSets'
% Feature vector
X = array2table([trSets; vSets; tSets]);
noFeat = length(selFeatures');
noChan = width(X)/noFeat;

for i=1:noFeat;
    for j = 1:noChan;
        xTitle{j+(i-1)*noChan} = [selFeatures{i},num2str(j)];
    end
end
X.Properties.VariableNames =  xTitle;
writetable(X,[path,'\X.csv']);

% Result vector
Y = array2table([trOuts; vOuts; tOuts]);
yName= movLables';
for i=1:length(movLables)
    yTitle{i} = yName{i}(find(~isspace(yName{i})));
end

Y.Properties.VariableNames = yTitle;
writetable(Y, [path,'\Y.csv']);

end
