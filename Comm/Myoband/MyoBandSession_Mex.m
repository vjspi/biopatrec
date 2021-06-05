classdef MyoBandSession_Mex < matlab.mixin.Heterogeneous & handle

    properties
       timerPeriod = 0.04 % period of acquisition timer in seconds
        sampleRate
        sampleStep % 1/sampleRate as serial timestamp
        duration % recording session duration
        durationSamples % duration in samples
        channelList % list of channels to return
        NotifyWhenDataAvailableExceeds % time in seconds, DataAvailable Event period    % Desired window size in samples
        % at this moment only one listener
        listenerEvent % event, listener expects
        listenerCallback % listener's callback function
        dataAvailableBuffer % buffer for DataAvailable event
        dataAvailableCounter % buffer's counter for filling status
        IsLogging % acquisition is in process
        timerHandle % handle for aquisition timer
        IsDone % acquisition is finished
%         filterA % butter filter parameter
%         filterB % butter filter parameter
%         FILTER_BUFFER_SIZE % butter filter's size
%         BUTTER_PADDING_SIZE % size, that will be ignored
%         filterBuffer % butter buffer
%         prefilterSamples % number of samples for prefiltering
        notifyOnlyOncePerIncoming = true
        myMyoMex
        myoData
        allData
        
        % Recorded data 
        emgData
        emgTime
        imuData
        imuTime
    end

    
    methods
        function session = MyoBandSession_Mex(sampleRate, duration, channelList)
            session.sampleRate = sampleRate;
            session.sampleStep = (datenum('00:00:02')-datenum('00:00:01'))/session.sampleRate;
            session.duration = duration;
            session.channelList = channelList;
%             [session.filterB,session.filterA]=butter(3,[.01,.99]);
%             session.FILTER_BUFFER_SIZE = session.sampleRate; % 1 second
%             session.BUTTER_PADDING_SIZE = 512;
%            session.filterBuffer = zeros(session.FILTER_BUFFER_SIZE+session.BUTTER_PADDING_SIZE, 22);
            % MyoClient('GetMyo');
            if exist('mm','var')  && isa(mm,'MyoMex'), delete(mm);  end
            if exist('tmr','var') && isa(tmr,'timer'), delete(tmr); end
            
        end
        
        function lh = addListener(session, eventName, listenerCallback)
            lh = 0;
            session.listenerEvent = eventName;
            session.listenerCallback = listenerCallback;
        end
        
        % same function as above but without capital L
        function lh = addlistener(session, eventName, listenerCallback)
            lh = 0;
            session.listenerEvent = eventName;
            session.listenerCallback = listenerCallback;
        end
        
        function startBackground(session)
            if session.IsLogging == true
                disp('Ongoing acquisition. Stop first.');
                return;
            end
            
            mm = MyoMex(1);
            session.myMyoMex = mm;
            session.myoData = session.myMyoMex.myoData;
            
            %Check if Myo actually on
            if session.myoData.isStreaming
                disp('Myo is streaming')
                session.IsLogging = true;
            end
                       
            session.durationSamples = session.duration * session.sampleRate;
            session.IsDone = false;
            
             %For plotting
            func = @(~,~)session.sample(); 
            session.timerHandle = timer('TimerFcn',func,'StartDelay',session.timerPeriod,'Period',session.timerPeriod,'ExecutionMode','fixedRate');
            
            start(session.timerHandle)
            
                       
        end
        
        % Data acquisition data callback function
        % Acquires samples from MyoClient, buffers, filters and fires
        % DataAvailable listener event.
        function sample(session)
            try
                
                if size(session.myoData.timeEMG_log,1) < session.durationSamples && session.IsDone == false
                    %add plotting code
%                     timeIMU = session.myoData.timeIMU_log;
                    timeEMG = session.myoData.timeEMG_log;
%                     quat = session.myoData.quat_log;
                    emg = session.myoData.emg_log;
% 
%                     % Compute logical indexes for the desired data
%                     %timeMax = max([timeIMU(end),timeEMG(end)]);
                    if size(timeEMG)>0
%                         timeMax = timeEMG(end);
%                         disp('No')
%                         idxIMU = timeIMU > timeMax-session.NotifyWhenDataAvailableExceeds;
%                         idxEMG = timeEMG > timeMax-session.NotifyWhenDataAvailableExceeds;
             
                        % Copy desired data
%                         tq = timeIMU(idxIMU);
%                         q = quat(idxIMU,:);
                        te = timeEMG(end-session.NotifyWhenDataAvailableExceeds+1:end);
                        emg = emg(end-session.NotifyWhenDataAvailableExceeds+1:end,:);
    %                     
                        event = struct('Data',emg,'TimeStamps',te,'TriggerTime',te(1));
                        session.listenerCallback(session,event);    %Display data (as mentioned in callback function)
                    end
                    
                else
                    session.IsDone = true;
                    stop(session.timerHandle);
                    
                    % saving the data  
                    % Data acquisition as long as sampling time
                    data = session.myoData.emg_log;
                    disp(['Need to cut off: ', num2str(size(data,1)-session.durationSamples)]);
                    session.emgData = data(1:session.durationSamples,:);
                    session.emgTime = session.myoData.timeEMG_log(1:session.durationSamples,:);
                    
                    % IMU Data - extracting fixed data (fixed to reference
                    % frame rather than in Myo Band coordinate system)
                    session.imuTime = session.myoData.timeIMU_log;
                    
                    %% Choose one of following lines to either capture data in Myo Frame or in fixed reference frame
                    session.imuData = [session.myoData.quat_log, session.myoData.accel_log, session.myoData.gyro_log, session.myoData.accel_fixed_log]; 
%                     session.imuData = [session.myoData.quat_log, session.myoData.accel_fixed_log, session.myoData.gyro_fixed_log]; 
                    
                end


                % Choose relevant data (last samples based on selected
                % window size)
%                 te = timeEMG(end-session.NotifyWhenDataAvailableExceeds+1:end,:);
%                 em = emg(end-session.NotifyWhenDataAvailableExceeds+1:end,:);
                               

            catch e
                getReport(e)
            end   
        end
        
        function wait(session)
            %if ~session.IsDone % Matlab fails.
            %    wait(session.timerHandle);
            %end
            pause on;
            while session.IsDone == false
                pause(session.timerPeriod);
            end
        end
        
        % Stop session
        function stop(session)
            if ~session.IsDone
                % stop(session.timerHandle);
                session.IsDone = true;
                session.IsLogging = false;
                session.myMyoMex.stopStreaming();
                
                delete(timerfindall);
                %MyoClient('StopSampling');
            end
        end
        
        function stopSampling(session)
            session.myMyoMex.stopStreaming();
        end
        
    end
end

    
