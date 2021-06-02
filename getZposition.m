% get z position
% requires a loaded recSession that recorded accel_fixed

close all
clear all

% load('C:\Users\spieker\LRZ Sync+Share\MasterThesis\20_Coding\DataSets\Position_IMU_Data\T2_DynPos-MovingUp_Sagittal&Coronal.mat')
% load('C:\Users\spieker\LRZ Sync+Share\MasterThesis\20_Coding\DataSets\Position_IMU_Data\T3_MovedUp&Down.mat')
load('C:\Users\spieker\LRZ Sync+Share\MasterThesis\20_Coding\DataSets\Position_IMU_Data\T4_DynPos-MovingUp_Sagittal4Pos&Coronal.mat')


%% Load Data
sF=200;
dt=1/sF;
grav = 9.81; % m/S^2
quat = recSession.imudata(:,1:4);
quat0 = quat(1,:);
quat_init = quatmultiply(quatconj(quat0),quat);

acc = recSession.imudata(:,5:7);

gyro = recSession.imudata(:,8:10);

eul_i = quat2eul(quat_init);           % ZYX

% acc = quatrotate(quat_init, acc);

acc_up = acc(:,3);

%% Plot quaternions
f = figure;

f_q = subplot(5,1,1);
plot(quat(:,1:4));
legend('1', 'x', 'y', 'z');
ylabel('Quat');

title('IMU Data')

f_qi = subplot(5,1,2);
plot(quat_init(:,1:4))
legend('w', 'x', 'y', 'z');
ylabel('Quat Initialized')

f_ei = subplot(5,1,3);
plot(eul_i)
legend('z', 'y', 'x');
ylabel('Euler Initialized')

f_a = subplot(5,1,4);
plot(acc);
legend('x', 'y', 'z');
ylabel('acc [g]');

f_g = subplot(5,1,5);
plot(gyro);
legend('x', 'y', 'z');
ylabel('gyr [deg/s]');

%% subtract G
gravity = [0, 0, -1];
gravity_rot  = quatrotate(quat_init, gravity);

acc_normG = acc_up + gravity_rot(1,3);

acc_oneG = acc_up - 1;

acc_initG = acc_up - acc_up(1);


%% Filter the signal 
% Create BP filter
[b, a] = butter(2,[1 20]/sF);
[b2, a2] = butter(2,[1 50]/sF);


% Create LP filter
[z,p,k] = butter(2, 20/sF,'low');
[sos_var,g] = zp2sos(z,p,k);


% acc_normG_lp =  filtfilt(b, a, acc_normG);
% acc_oneG_lp =  filtfilt(b, a, acc_oneG);
% acc_initG_lp =  filtfilt(b, a, acc_initG);
acc_bp = filtfilt(b, a, acc_oneG);
acc_lp = filtfilt(sos_var, g, acc_up);


% acc_normG_lp =  filtfilt(sos_var,g,acc_normG);
% acc_oneG_lp =  filtfilt(sos_var,g,acc_oneG);
% acc_initG_lp =  filtfilt(sos_var,g,acc_initG);

%% Add noise reduction:
% acc_noise = acc_lp;
% acc_noise(abs(acc_noise) < 0.05) = 0;
% acc_noise_lp(abs(acc_noise_lp) < 0.02) = 0;

%% Integration
z_normG= zeros(size(acc,1),1);
z_oneG = zeros(size(acc,1),1);
z_initG = zeros(size(acc,1),1);

v_normG = zeros(size(acc,1),1);
v_oneG = zeros(size(acc,1),1);
v_initG = zeros(size(acc,1),1);

for i=2:length(acc)
    
    acc_dif = abs(acc_lp(i) - acc_lp(i-1));
    % v = a * t + v0
    % s = 0.5 * a * t^2 + v0 * t + s0
    
    v_normG(i) = acc_lp(i) * grav * dt + v_normG(i-1);
%     v_oneG(i) = acc_oneG_lp(i) * grav * dt + v_oneG(i-1);
%     v_initG(i) = acc_initG_lp(i) * grav * dt + v_initG(i-1);

    
    if  abs(acc_lp(i)) > 0;
        z_normG(i) = 0.5 * acc_lp(i) * grav * dt^2 + v_normG(i-1) * dt + z_normG(i-1);
%         z_oneG(i) = 0.5 * acc_oneG_lp(i) * grav * dt^2 + v_oneG(i-1) * dt + z_oneG(i-1);
%         z_initG(i) = 0.5 * acc_initG_lp(i) * grav * dt^2 + v_initG(i-1) * dt + z_initG(i-1);
    else 
%         v_normG(i) = v_normG(i-1);
%         v_initG(i) = v_initG(i-1);
       
        z_normG(i)=z_normG(i-1);
%         z_initG(i)=z_initG(i-1);
    end
    
    % using Cumtrapz
%     v_normG(i) = 
end


%% Plot acceleration
graph = figure;

g_a = subplot(2,1,1);
hold on
plot(acc_up, 'black', 'DisplayName','Raw');
plot(acc_lp, 'red', 'DisplayName','BP filtered');

title('IMU: Acceleration in Z-direction');
xlabel('Sample number (200Hz)'); ylabel('Acceleration in g');
legend;

% g_s = subplot(3,1,2);
% hold on
% plot(z_normG*10^3,  'black', 'DisplayName', 'G_z = 1');
% % plot(z_oneG*10^3,  'blue', 'DisplayName', 'G_z = 1 ');
% plot(z_initG*10^3,  'red', 'DisplayName','G_z = z_{acc}(1) ');
% title('Estimated Z Position ')
% xlabel('Sample number (200Hz)'); ylabel('Position in mm');
% legend

s_true = subplot(2,1,2);
hold on
time = 0:(1/sF):(1/sF*(length(quat)-1));
a = acc_bp * grav;

% First integration
v = cumtrapz(time, a);
v_lp =  filtfilt(b2, a2 ,v);

% Second integration
s =  cumtrapz(time,v);
s_lp = cumtrapz(time,v_lp);


plot(time, acc_bp,  'DisplayName', 'a in g [9,81 m/s^2]');
plot(time, v, 'DisplayName', 'v in m/s (raw)');
plot(time, v_lp, 'DisplayName', 'v in m/s (BP filtered)');
plot(time, s_lp, 'DisplayName', 's in m');
legend;
title('Integration of acceleration')


%% Complementary filter
acc_r = quatrotate(quat_init, acc);
gyro_r = quatrotate(quat, gyro);
gravity = [0, 0, -1];
gravity_rot  = quatrotate(quat_init, gravity);

% h = figure
% subplot(3,1,1);
% plot(acc_r);
% legend('x', 'y', 'z');
% subplot(3,1,2);
% plot(gyro_r);
% subplot(3,1,3);
% plot(gravity_rot);
% legend('x', 'y', 'z');
% 

