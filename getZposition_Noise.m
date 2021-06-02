% Fourier transform

% load('C:\Users\spieker\LRZ Sync+Share\MasterThesis\20_Coding\DataSets\Position_IMU_Data\DynPos-MovingUp_Sagittal&Coronal.mat')
load('C:\Users\spieker\LRZ Sync+Share\MasterThesis\20_Coding\DataSets\Position_IMU_Data\T2_DynPos-MovingUp_Sagittal&Coronal.mat')

acc = recSession.imudata(:,5:7);
acc_up = acc(:,3);


Fs = 200;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(acc_up);   % Length of signal
t = (0:L-1)*T;        % Time vector

Y = fft(acc_up);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

fig=figure;

f = Fs*(0:(L/2))/L;

plot(f,P1) 
title('Single-Sided Amplitude Spectrum of a(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

% Velocity
% First integration
v = cumtrapz(time, acc_up * grav);
Y_v = fft(acc_up);

P2 = abs(Y_v/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

fig=figure;

s = Fs*(0:(L/2))/L;

plot(s,P1) 
title('Single-Sided Amplitude Spectrum of v(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')