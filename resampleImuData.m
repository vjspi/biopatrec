function recSessionIMU = resampleImuData(sF, sTall, imuTime, imuData, emgTime)

% New (ideal) time vector - doublecheck with EMG time vector
t = (0:(1/sF):(sTall-(1/sF)))';

% IMU recording starts later
% Current walkaround: extrapolate for the area
recSessionIMU = interp1(imuTime, imuData, emgTime, 'linear', 'extrap');

%% Beginning of different approch: Pad first samples
% Find first time stamp corresponding to IMU data
% for i=1:size(t)
%     if emgTime(i) > imuTime(1) 
%         break
%     end 
% end
% 
% %% pad samples
% offsetStart = imuTime(1)-emgTime(1);
% if offsetStart > (1/sF)
%     noOffsetStart = floor(offsetStart/(4/sF));
% end

    



end

