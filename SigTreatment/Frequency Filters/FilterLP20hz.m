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
% [Give a short summary about the principle of your function here.]
%
% ------------------------- Updates & Contributors ------------------------
% [Contributors are welcome to add their email]
% 20xx-xx-xx / Max Ortiz  / Creation
% 2021-06-08 / Veronika Spieker  / Modified for kinematic data processing
% (IMU)
% 20xx-xx-xx / Author  / Comment on update


function [dataf] = FilterLP20hz (Fs, data)

N  = 4;  % Order
Fc = 20;  % Cutoff Frequency

% Calculate the zpk values using the BUTTER function.
[z,p,k] = butter(N, Fc/(Fs/2), 'low');
[sos_var,g] = zp2sos(z,p,k);

dataf = filtfilt(sos_var, g, data);



