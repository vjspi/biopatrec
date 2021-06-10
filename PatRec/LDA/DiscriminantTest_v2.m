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
% Function to execute the discrimant analysis use the coeficient previusly
% calculated
%
% ------------------------- Updates & Contributors ------------------------
% [Contributors are welcome to add their email]
% 2011-08-01 / Max Ortiz / Created
% 2011-10-02 / Max Ortiz / Modified to return outVector and outMov

function [outMov, outCI] = DiscriminantTest_v2(classifier, tSet, dType)

   [stOutMov, outCI] = predict(classifier, tSet);                      % outputs the string
   outMov = find(strcmp(classifier.ClassNames, stOutMov));                          % Convert label to index      

end