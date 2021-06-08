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
% ------------------- Function Description ------------------
% Function to Record Exc Sessions
%
% --------------------------Updates--------------------------
% 2015-01-26 / Enzo Mastinu / A new GUI_Recordings has been developed for the
                            % BioPatRec_TRE release. Now it is possible to
                            % plot more then 8 channels at the same moment, for 
                            % time and frequency plots both. It is faster and
                            % perfectly compatible with the ramp recording 
                            % session. At the end of the recording session it 
                            % is possible to check all channels individually, 
                            % apply offline data process as feature extraction or filter etc.
% 2015-10-28 / Martin Holder / >2014b plot interface fixes

% 2017-09-25 / Simon Nilsson  / Added warning dialog if acquisition error occurs

% 2018-07-09 / Andreas Eiler / Added function to change current folder to load
                            % Myo.dll file correctly



function [cdata, sF, sT] = FastRecordingSession(varargin)

    global       handles;
    global       allData;
    global       timeStamps;
    global       samplesCounter;
    allData      = [];
    handles      = varargin{1};
    afeSettings  = varargin{2};

    % Get required informations from afeSettings structure
    nCh          = afeSettings.channels;
    sF           = afeSettings.sampleRate;
    deviceName   = afeSettings.name;
    ComPortType  = afeSettings.ComPortType;
    if strcmp(ComPortType, 'COM')
        ComPortName = afeSettings.ComPortName;  
    end
    
    % Save back acquisition parameters to the handles
    handles.nCh         = nCh;
    handles.sF          = sF;
    handles.ComPortType = ComPortType;
    if strcmp(ComPortType, 'COM')
        handles.ComPortName = ComPortName;     
    end
    handles.deviceName  = deviceName;
    % To avoid bugs in RecordingSession_ShowData function
    handles.fast        = 1;
    handles.rep         = 1;                                               
    handles.cT          = 0;
    handles.rT          = 0;
    handles.rampStatus  = 0;
    
    % Setting for data peeking
    sT            = handles.sT;
    handles.sT    = sT;
    handles.sTall = sT;
    tW            = handles.tW;
    tWs           = tW*sF;                                                 % Time window samples
    handles.tWs   = tWs;
    timeStamps    = 0:1/sF:tW-1/sF;                                        % Create vector of time
    
    
    %% Initialize GUI..

    pause on;
    
    % Initialize plots, offset the data
    ampPP = 5;
    sData = zeros(tWs,nCh);   
    fData = zeros(tWs,nCh);
    offVector = 0:nCh-1;
    offVector = offVector .* ampPP;
    for i = 1 : nCh
        sData(:,i) = sData(:,i) + offVector(i);
        fData(:,i) = fData(:,i) + offVector(i);
    end
    
    % Draw figure
    ymin = -ampPP*2/3;
    ymax =  ampPP * nCh - ampPP*1/3;
    p_t0 = plot(handles.a_t0, timeStamps, sData);
    handles.p_t0 = p_t0;
    xlim(handles.a_t0, [timeStamps(1) timeStamps(end)]);
    set(handles.a_t0,'XTick',0:numel(timeStamps)-1);
    set(handles.a_t0,'XTickLabel',timeStamps);
    ylim(handles.a_t0, [ymin ymax]);
    set(handles.a_t0,'YTick',offVector);
    set(handles.a_t0,'YTickLabel',0:nCh-1);
    p_f0 = plot(handles.a_f0,timeStamps,fData);
    handles.p_f0 = p_f0;  
    xlim(handles.a_f0, [0,sF/2]);
    ylim(handles.a_f0, [ymin ymax]);
    set(handles.a_f0,'YTick',offVector);
    set(handles.a_f0,'YTickLabel',0:nCh-1);
    
    
    % Initialization of progress bar
    xpatch = [0 0 0 0];
    ypatch = [0 0 1 1];
    axes(handles.a_prog);
    axis(handles.a_prog,'off');
    set(handles.a_prog,'XLimMode','manual');
    handles.hPatch = patch(xpatch,ypatch,'b','EdgeColor','b','visible','on');
    drawnow update % 2014b figure updates

    
    % Allocation of resource to improve speed, total data 
    recSessionData = zeros(sF*sT, nCh);
    nIMU = 10;
    recSessionIMU = zeros(sF*sT, nIMU);



    %% Starting Session..
    
    % Warning to the user
    set(handles.t_msg,'String','start');
    drawnow;

    % Run 
    currentTv = 1;                                                     % Current time vector
    tV = timeStamps(currentTv):1/sF:(tW-1/sF)+timeStamps(currentTv);   % Time vector used for drawing graphics
    currentTv = currentTv - 1 + tWs;                                   % Updated everytime tV is updated
    acquireEvent.TimeStamps = tV';

    %%%%% NI DAQ card %%%%%
    if strcmp (ComPortType, 'NI')

        % Init SBI
        sCh = 1:nCh;
        if strcmp(deviceName, 'Thalmic MyoBand') 
            %CK: init MyoBand
            originFolder = pwd;
            changeFolderToMyoDLL();
            pause (0.5);
            s = MyoBandSession(sF, sT, sCh);
            cd (originFolder);
        elseif strcmp(deviceName, 'Myo_test')
            %CK: init MyoBand
            originFolder = pwd;
            changeFolderToMyoMex();
            pause (0.5);
            s = MyoBandSession_Mex(sF, sT, sCh);
            cd (originFolder);
        else
            s = InitSBI_NI(sF,sT,sCh);
        end
        s.NotifyWhenDataAvailableExceeds = tWs;                        % PEEK time
        lh = s.addlistener('DataAvailable', @RecordingSession_ShowData);   

        % Start DAQ
        cData = zeros(sF*sT, nCh);
        imuData = zeros(sF*sT, 7);  % 7 values for 4 quaternions and 3 accelerometer
        s.startBackground();                                           % Run in the backgroud

        startTimerTic = tic;
        disp(['Pausing: ', num2str(sT - toc(startTimerTic))]);
        pause(sT - toc(startTimerTic)); %                               % Wait until desired sampling time passes
        % pause(sT);


    % Repetitions other devices     
    else

        % Connect the chosen device, it returns the connection object
        obj = ConnectDevice(handles);
        if strcmp(get(obj,'Status'),'closed')   % Make sure port opened correctly
            return;
        end
        
        % Set the selected device and Start the acquisition
        SetDeviceStartAcquisition(handles, obj);
        if strcmp(get(obj,'Status'),'closed')   % StartAcquisition closes the port on failure
            return;
        end
        
        samplesCounter = 1;  

        samplesCounter = 1;
        cData = zeros(tWs, nCh);  

        for timeWindowNr = 1:sT/tW
            [cData, error] = Acquire_tWs(deviceName, obj, nCh, tWs);    % acquire a new time window of samples  
            if error == 1
                errordlg('Error occurred during the acquisition!','Error');
                return
            end
            acquireEvent.Data = cData;
            RecordingSession_ShowData(0, acquireEvent);            % plot data and add cData to allData vector
            samplesCounter = samplesCounter + tWs;
        end

        % Stop acquisition
        StopAcquisition(deviceName, obj); 
        
    end

    % NI DAQ card: "You must delete the listener once the operation is complete"
    if strcmp(ComPortType,'NI')  
        if ~s.IsDone                                                   % check if is done
            s.wait();
        end
        if ~strcmp(deviceName, 'Thalmic MyoBand') && ~strcmp(deviceName, 'Myo_test') 
            delete(lh);
        end
        %CK: Stop sampling from MyoBand
        if strcmp(deviceName, 'Thalmic MyoBand') 
%             s.stop(); 
            MyoClient('StopSampling');
        elseif strcmp(deviceName, 'Myo_test') 
            allData = s.emgData;
            imuData = s.imuData;
            imuTime = s.imuTime;
            emgTime = s.emgTime;
            s.emgData = [];  
            s.imuData = []; 
            s.emgTime = [];  
            s.imuTime = []; 
                            
              delete(s.myMyoMex);       %deleting the MatMex object (opened in the beginning)
              s.stop();
     
        end
    end

    % Save Data
    recSessionData = allData;
    if strcmp(deviceName, 'Myo_test')
        tic;
        recSessionIMU = interp1(imuTime, imuData, emgTime, 'linear', 'extrap');
        toc;
    end
            
    
    %% Session finish..
    set(handles.t_msg,'String','Session Terminated');                  % Show message about acquisition completed     
    fileName = 'Img/Agree.jpg';
    movI = importdata(fileName);                                       % Import Image
    set(handles.a_pic,'Visible','on');                                 % Turn on visibility
    image(movI,'Parent',handles.a_pic);                          % set image
    axis(handles.a_pic,'off');                                         % Remove axis tick marks
    set(handles.a_prog,'visible','off');
    set(handles.hPatch,'Xdata',[0 0 0 0]);

    % Data Plot
    cdata = recSessionData;
    idata = recSessionIMU;
   
    if strcmp(deviceName, 'Myo_test') 
        DataShowIMU(handles, cdata(:,1:handles.nCh), idata, sF, sT);
    else
         DataShow(handles,cdata(:,1:handles.nCh),sF,sT);
    end
         
    
    % Set visible the offline plot and process panels
    set(handles.uipanel9,'Visible','on');   
    set(handles.uipanel7,'Visible','on');
    set(handles.uipanel8,'Visible','on');
    set(handles.txt_it,'visible','on');
    set(handles.txt_ft,'visible','on');
    set(handles.et_it,'visible','on');
    set(handles.et_ft,'visible','on');
    set(handles.txt_if,'visible','on');
    set(handles.txt_ff,'visible','on');
    set(handles.et_if,'visible','on');
    set(handles.et_ff,'visible','on');
    
    chVector = 0:nCh-1;
    set(handles.lb_channels, 'String', chVector);
   
    [filename, pathname] = uiputfile({'*.mat','MAT-files (*.mat)'},'Save as', 'Untitled.mat');
    
        if strcmp(deviceName, 'Myo_test')
            eul = quat2eul(idata(:,1:4));
            save([pathname,filename],'cdata','idata','eul','sF','sT','nCh','ComPortType','deviceName');
        end
        
        
end
