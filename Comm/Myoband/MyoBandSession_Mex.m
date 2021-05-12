classdef MyoBandSession_Mex < matlab.mixin.Heterogeneous & handle

    properties
       timerPeriod = 0.04 % period of acquisition timer in seconds
        sampleRate
        sampleStep % 1/sampleRate as serial timestamp
        duration % recording session duration
        durationSamples % duration in samples
        channelList % list of channels to return
        NotifyWhenDataAvailableExceeds % time in seconds, DataAvailable Event period
        % at this moment only one listener
        listenerEvent % event, listener expects
        listenerCallback % listener's callback function
        dataAvailableBuffer % buffer for DataAvailable event
        dataAvailableCounter % buffer's counter for filling status
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
        myMyoMex
        myoData
    end

    
    methods
        function session = MyoBandSession_Mex(sampleRate, duration, channelList)
            session.sampleRate = sampleRate;
            session.sampleStep = (datenum('00:00:02')-datenum('00:00:01'))/session.sampleRate;
            session.duration = duration;
            session.channelList = channelList;
            [session.filterB,session.filterA]=butter(3,[.01,.99]);
            session.FILTER_BUFFER_SIZE = session.sampleRate; % 1 second
            session.BUTTER_PADDING_SIZE = 512;
            session.filterBuffer = zeros(session.FILTER_BUFFER_SIZE+session.BUTTER_PADDING_SIZE, 22);
            % MyoClient('GetMyo');
            if exist('mm','var')  && isa(mm,'MyoMex'), delete(mm);  end
            if exist('tmr','var') && isa(tmr,'timer'), delete(tmr); end
            
            mm = MyoMex(1);
            session.myMyoMex = mm;
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
            
            session.dataAvailableBuffer = zeros(floor(session.NotifyWhenDataAvailableExceeds), length(session.channelList));
            
            session.dataAvailableCounter = 0;
            %MyoClient('StartSampling', session.sampleRate);
            

            %MyoClient('StartSampling');
            session.myoData = session.myMyoMex.myoData;
            
            %Check
            if session.myoData.isStreaming
                disp('Myo is streaming')
            end
            
                  
            count = 1024;
            pause on;
            while count == 1024
                disp(['flush count ' mat2str(count)]);
                %[packet, packetTime] = s MyoClient('SampleEmg'); % flush
                packet = session.myoData.emg_log; 
                % disp(packet);
                %[orientation, orientationTime] = MyoClient('SampleOrientation');% flush
                orientation = session.myoData.quat_log; 
                %disp(orientation);
                %event = MyoClient('SampleEvents'); % flush
                % disp(event)
                disp(['flush packet ' mat2str(size(packet))]);
                count = size(packet,2);
                pause(0.2);
                count_imu = size(orientation);
                disp(['flush packet orientation ' mat2str(size(orientation))]);
                %disp(count);
                %pause(0.2);
            end
            start(session.timerHandle); % Call sample function
            % pause for prefiltering; block!
            %pause on;
            %pause(session.BUTTER_PADDING_SIZE/session.sampleRate);
        end
        
        % Data acquisition data callback function
        % Acquires samples from MyoClient, buffers, filters and fires
        % DataAvailable listener event.
        function sample(session)
            try
            % CK: 'packetTime' is probably unnecessary    
            %[packet, packetTime] = s MyoClient('SampleEmg'); % flush
            packet = session.myoData.emg_log; 
            packet = packet(end-9:end, :);
            disp(['Size EMG ' mat2str(size(packet))]);
            % plot(packet)
            % CK: next 2 calls are necessary because otherwise an overflow 
            % occurs and the MyoBand stops working properly (I think)
            %[orientation, orientationTime] = MyoClient('SampleOrientation');% flush
            orientation = session.myoData.quat;
            disp(['Size orientation ' mat2str(size(orientation))]);
            % disp(orientation)
            % plot(orientation)
            % event = MyoClient('SampleEvents');
            
            count = size(packet,1);           % Index changed compared to MyoClient (because channels already correspond to columns)
            %disp(['packet ' num2str(count)]);
            %disp(['dataAvailableBuffer ' mat2str(size(session.dataAvailableBuffer))]);
            
            if count > 0 && session.IsDone == false
                
                % transpose packet for filtering and event
               %packet = packet';
                             
               
               % filter
                % packet might be larger than butter buffer, therefore
                % partition is necessary
%                 filteredPacket = zeros(size(packet));
%                 filteredPacketCounter = 0;
%                 while filteredPacketCounter < count
%                     toFilter = min(count-filteredPacketCounter, ...
%                         session.FILTER_BUFFER_SIZE);
%                     session.filterBuffer = vertcat(session.filterBuffer(toFilter+1:end,:), ...
%                         packet(filteredPacketCounter+1:filteredPacketCounter+toFilter,:));
%                     tempBuffer = filter(session.filterB, session.filterA, session.filterBuffer(:,:));
%                     filteredPacket(filteredPacketCounter+1:filteredPacketCounter+toFilter,:) = ...
%                         tempBuffer(end-toFilter+1:end,:);
%                     filteredPacketCounter = filteredPacketCounter + toFilter;
%                 end
%                 
%                 packet = filteredPacket;
%                 TODO: maybe filter after channel mapping for more
%                 performance
%                 
%                 drop packets for prefiltering
%                 if session.prefilterSamples > 0
%                     toDrop = min(session.prefilterSamples, count);
%                     session.prefilterSamples = session.prefilterSamples - toDrop;
%                     count = count - toDrop;
%                     if count > 0
%                         packet = packet(toDrop+1:end,:);
%                     else
%                         return;
%                     end
%                 end
                
                % prepare final data buffer
                % data = zeros(length(session.channelList), count);
                data = zeros(count, length(session.channelList));   %original - VS: number of samples as incoming (packet)
                % channel mapping
                % disp(['channel index '  num2str(session.channelList)]);
                
                for channelIx=1:length(session.channelList)
                    channelId = session.channelList(channelIx);
                    data(:,channelIx) = packet(:,channelId);
                end
                
                data_imu = orientation';                
                
                %plot(data)
                % disp(['data ' mat2str(size(data))]);
                %disp(session.notifyOnlyOncePerIncoming);
                
                % VS: Avoid double use of the data and therefore cut to the desired window?
                if session.notifyOnlyOncePerIncoming
                    if size(data,1) > floor(session.NotifyWhenDataAvailableExceeds)
                        disp(['Before cut' mat2str(size(data))]);
                        data = data(end-floor(session.NotifyWhenDataAvailableExceeds)+1:end,:);
                        disp(['After cut' mat2str(size(data))]);
                        count = size(data,1);
                        disp(['Count after DatAvailableExceeds' mat2str(size(data))]);
                        
                        % Cut IMU data as well
                        imu_samples = floor(session.NotifyWhenDataAvailableExceeds/4);
                        data_imu=data_imu(end-imu_samples+1:end,:);
                    end
                end
                
                % put data into DataAvailable buffer and fire events until
                % whole packet is consumed 
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
                    session.dataAvailableCounter = session.dataAvailableCounter + toAppend;
                    
                    session.durationSamples = session.durationSamples - toAppend;

                    % if buffer full do event
                    if session.dataAvailableCounter == length(session.dataAvailableBuffer) || session.durationSamples == 0
                        
                        % compute timestamps for last samples from this
                        % point in time into the past
                        after = now;
                        timestamps = fliplr(1:session.dataAvailableCounter);
                        timestamps = after - (timestamps*session.sampleStep);
                        disp(['Computed ' mat2str(length(timestamps)) ' timestamps']);
                        % prepare event
                        event = struct('Data',session.dataAvailableBuffer(1:session.dataAvailableCounter,:) ...
                            ,'TimeStamps',timestamps','TriggerTime',timestamps(1));
                        % call listener callback
                        if ~session.notifyOnlyOncePerIncoming || count<size(session.dataAvailableBuffer,1)
                            try
                                session.listenerCallback(session,event);
                            catch e
                                disp('MyoBandRecordingSession failed, trying to move on');
                                getReport(e)
                            end
                        end
                        % reset DataAvailable buffer
                        session.dataAvailableCounter = 0;
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