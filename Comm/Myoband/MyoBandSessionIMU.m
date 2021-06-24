classdef MyoBandSessionIMU < matlab.mixin.Heterogeneous & handle

    properties
       timerPeriod = 0.04 % period of acquisition timer in seconds
        sampleRate
        sampleStep % 1/sampleRate as serial timestamp
        duration % recording session duration
        durationSamples % duration in samples
        channelList % list of channels to return
        imuLength   % amount of IMU data that should be published (Orientation: quat(4), acc(3), gyr(3))
        NotifyWhenDataAvailableExceeds % time in seconds, DataAvailable Event per
        NotifyWhenIMUAvailableExceeds
        % at this moment only one listener
        listenerEvent % event, listener expects
        listenerCallback % listener's callback function
        dataAvailableBuffer % buffer for DataAvailable event
        dataAvailableCounter % buffer's counter for filling status
        imuAvailableBuffer % buffer for IMU data Available event
        imuAvailableCounter % buffer's counter for IMU data filling status
        IsLogging % acquisition is in process
        timerHandle % handle for aquisition timer
        IsDone % acquisition is finished
        filterA % butter filter parameter
        filterB % butter filter parameter
        FILTER_BUFFER_SIZE % butter filter's size
        BUTTER_PADDING_SIZE % size, that will be ignored
        filterBuffer % butter buffer
        prefilterSamples % number of samples for prefiltering
        notifyOnlyOncePerIncoming = true
    end

    
    methods
        function session = MyoBandSessionIMU(sampleRate, duration, channelList)
            session.sampleRate = sampleRate;
            session.sampleStep = (datenum('00:00:02')-datenum('00:00:01'))/session.sampleRate;
            session.duration = duration;
            session.channelList = channelList;
            session.imuLength = 4;                        % Four values should be publishe
            [session.filterB,session.filterA]=butter(3,[.01,.99]);
            session.FILTER_BUFFER_SIZE = session.sampleRate; % 1 second
            session.BUTTER_PADDING_SIZE = 512;
            session.filterBuffer = zeros(session.FILTER_BUFFER_SIZE+session.BUTTER_PADDING_SIZE, 22);
            MyoClient('GetMyo');
            
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
            func = @(~,~)session.sample();
            session.timerHandle = timer('TimerFcn',func,'StartDelay',session.timerPeriod,'Period',session.timerPeriod,'ExecutionMode','fixedRate');
            session.durationSamples = session.duration * session.sampleRate;
            session.IsLogging = true;
            session.IsDone = false;
            session.prefilterSamples = session.BUTTER_PADDING_SIZE; % TODO: test if smaller delay is possible
            
            session.NotifyWhenIMUAvailableExceeds = floor(session.NotifyWhenDataAvailableExceeds/4);
            
            session.dataAvailableBuffer = zeros(floor(session.NotifyWhenDataAvailableExceeds), length(session.channelList));
            session.imuAvailableBuffer = zeros(session.NotifyWhenIMUAvailableExceeds, session.imuLength);
            
            session.dataAvailableCounter = 0;
            session.imuAvailableCounter = 0;
            
            %MyoClient('StartSampling', session.sampleRate);
            MyoClient('StartSampling');
            count = 1024;
            pause on;
            while count == 1024
                disp(['flush count ' mat2str(count)]);
                [packet, packetTime] = MyoClient('SampleEmg'); % flush
                % disp(packet);
                [orientation, orientationTime] = MyoClient('SampleOrientation');% flush
                %disp(orientation);
                event = MyoClient('SampleEvents'); % flush
                % disp(event)
                disp(['flush packet ' mat2str(size(packet))]);
                count = size(packet,2);
                pause(0.05);
                count_imu = size(orientation);
%                 disp(['flush packet orientation ' mat2str(size(orientation))]);
                %disp(count);
                %pause(0.2);
            end
            start(session.timerHandle);
            % pause for prefiltering; block!
            %pause on;
            %pause(session.BUTTER_PADDING_SIZE/session.sampleRate);
        end
        
        % Data acquisition data callback function
        % Acquires samples from MyoClient, buffers, filters and fires
        % DataAvailable listener event.
        function sample(session)
            disp('New sample execution')
            try
            % CK: 'packetTime' is probably unnecessary    
            [packet, packetTime] = MyoClient('SampleEmg');
%             disp(['Size EMG ' mat2str(size(packet))]);
            % plot(packet)
            % CK: next 2 calls are necessary because otherwise an overflow 
            % occurs and the MyoBand stops working properly (I think)
            [orientation, orientationTime] = MyoClient('SampleOrientation');
            % disp(['Size orientation ' mat2str(size(orientation))]);
            % disp(orientation)
            % plot(orientation)
            event = MyoClient('SampleEvents');  % Not needed
            
            count = size(packet,2);             % Not yet transposed
            count_imu = size(orientation, 2);   % Not yet transposed
            %disp(['packet ' num2str(count)]);
            %disp(['dataAvailableBuffer ' mat2str(size(session.dataAvailableBuffer))]);
            
            if count > 0 && session.IsDone == false
                
                %%% transpose packet for filtering and event
                packet = packet';
                quat = orientation(1:session.imuLength,:)';     
                % disp('Quat '); disp(quat);
                               
                %%% prepare final data buffer
                % data = zeros(length(session.channelList), count);
                data = zeros(count, length(session.channelList));   % original - VS: number of samples as incoming (packet)
                % data_imu = zeros(floor(count/4), session.imuLength);
                
                %%% channel mapping
                for channelIx=1:length(session.channelList)
                    channelId = session.channelList(channelIx);
                    data(:,channelIx) = packet(:,channelId);
                end
                
                %%% imu mapping (could potentially be expanded to select
                %%% desired IMU information from GUI)
                data_imu = [quat(:,4), quat(:,1:3)];                   % reorder (because w is in the last place but later processing (quat2eul) requires it in the first 
                
                % plot(data)
                % disp(['data ' mat2str(size(data))]);
                % disp(session.notifyOnlyOncePerIncoming);
                 
                %%% If too many samples come in -> cut to the required amoutn
                % Avoid double use of the data and therefore cut to the desired window?
                if session.notifyOnlyOncePerIncoming
                    if size(data,1) > floor(session.NotifyWhenDataAvailableExceeds) %NotifyWhen... is the number of samples of selected timeWindow
%                         disp(['Before cut EMG ' mat2str(size(data))]);
%                         disp(['Before cut IMU ' mat2str(size(data_imu))]);
                        data = data(end-floor(session.NotifyWhenDataAvailableExceeds)+1:end,:);
%                         disp(num2str(length(data_imu)-session.NotifyWhenIMUAvailableExceeds+1));
                        data_imu = data_imu(end-session.NotifyWhenIMUAvailableExceeds+1:end,:);
%                         disp(['After cut EMG ' mat2str(size(data))]);
%                         disp(['After cut IMU ' mat2str(size(data_imu))]);
                        count = size(data,1);               % Now transposed
                        count_imu = size(data_imu, 1);      % Now transposed
%                         disp(['Count after DataAvailableExceeds' mat2str(size(data))]);                        
                    end
                end
                
                %%% put data into DataAvailable buffer and fire events until whole packet is consumed 
                % VS: loop until 10 samples are recorded
                while count > 0 && session.IsDone == false
                
                    % put packet into DataAvailable buffer
                    % VS: identify number of samples to append -> either the number of samples still required for total recording(durSamples) 
                    % or (the number of available samples (count) or required samples to fill buffer(difference))
                    toAppend = min(session.durationSamples,min(count, length(session.dataAvailableBuffer) - session.dataAvailableCounter));
                    disp(['Appending ' mat2str(toAppend) ' samples']);
                    session.dataAvailableBuffer(session.dataAvailableCounter+1:session.dataAvailableCounter+toAppend,:) = ...
                        data(1:toAppend,:);
                    data = data(toAppend+1:end,:);
                    count = count - toAppend;
%                     disp(data);
%                     disp(size(data_imu));
%                     disp(data_imu);
%                     disp(['Count EMG: ', num2str(count)]);
                    
                    session.dataAvailableCounter = session.dataAvailableCounter + toAppend;
                    session.durationSamples = session.durationSamples - toAppend;
                    
                    %%% Cut IMU data (which comes at a lower sampling rate) - in case of Myo at least 2 IMU samples per 10 samples EMG)
                    if count_imu > 0
%                         disp(['Count IMU: ', num2str(count_imu)]);
                        toAppend_imu = min(session.NotifyWhenIMUAvailableExceeds, min(count_imu, length(session.imuAvailableBuffer) - session.imuAvailableCounter));
%                         disp(['IMU to append ', num2str(toAppend_imu)]);
%                         disp(data_imu);
                        session.imuAvailableBuffer(session.imuAvailableCounter+1:session.imuAvailableCounter+toAppend_imu,:) = data_imu(1:toAppend_imu,:);
                        session.imuAvailableCounter = session.imuAvailableCounter + toAppend_imu;
                        count_imu = count_imu - toAppend_imu;
%                         disp(['Count IMU: ', num2str(count_imu)]);
                    end
                   
                    %%% if buffer full do event
                    if session.dataAvailableCounter == length(session.dataAvailableBuffer) || session.durationSamples == 0
                                                
                        % compute timestamps for last samples from this
                        % point in time into the past
                        after = now;
                        timestamps = fliplr(1:session.dataAvailableCounter);
                        timestamps = after - (timestamps*session.sampleStep);
                        quatMeanTemp = mean(session.imuAvailableBuffer(1:session.imuAvailableCounter,:),1);
                        quatMean = repmat(quatMeanTemp,length(timestamps),1);
                        disp(['Computed ' mat2str(length(timestamps)) ' timestamps']);
%                         disp(session.dataAvailableBuffer(1:session.dataAvailableCounter,:));
%                         disp(session.imuAvailableBuffer(1:session.imuAvailableCounter,:));
%                         disp(quatMean);
                        
                        
                        %%% prepare event
                        event = struct('Data',session.dataAvailableBuffer(1:session.dataAvailableCounter,:), ...
                            'IMU', quatMean , 'TimeStamps',timestamps','TriggerTime',timestamps(1));
                        % call listener callback
                        if ~session.notifyOnlyOncePerIncoming || count<size(session.dataAvailableBuffer,1) %???
                            try
                                session.listenerCallback(session,event);    %Display data (as mentioned in callback function)
                            catch e
                                disp('MyoBandRecordingSession failed, trying to move on');
                                getReport(e)
                            end
                        end
                        % reset DataAvailable buffer
                        session.dataAvailableCounter = 0;
                        session.imuAvailableCounter = 0;
                    end

                    % stop acquisition
                    if session.durationSamples == 0
                        session.IsDone = true;
                        session.IsLogging = false;
                        stop(session.timerHandle);
                        %MyoClient('StopSampling');
                    end
                    
                    
                end
            end
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
                stop(session.timerHandle);
                session.IsDone = true;
                session.IsLogging = false;
                MyoClient('StopSampling');
            end
        end
        function stopSampling(session)
            MyoClient('StopSampling');
        end
    end
end