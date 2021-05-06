% Script to activate MyoArmBand

close all

sF = 200;
sTall = 5; % Recording time
sCh = 8;
nCh = 8;
nM = 4;


originFolder = pwd;
changeFolderToMyoDLL();
pause (0.5);
s = MyoBandSession(sF, sTall, sCh);
o = MyoBandSession(sF/4, sTall, sCh);
cd (originFolder);

lh = s.addlistener('DataAvailable', @listen);

% cData = zeros(sF*sTall, nCh, nM);
s.startBackground();  
%o.startBackground();

% allData = [allData; tempData];
        
MyoClient('StopSampling');

disp('yes')


function listen(src, event)
    global      allData;
    if(isempty(allData))                                                   % Fist DAQ callback
        timeStamps = [];
        % the variable plotGain must be reloaded on every starting of a new
        % recording, the reason of set it on a huge values is that in this
        % way we are sure that this value will be overwritten with a lower
        % value, see the code below for more details
        plotGain = 10000000;
    end
    
    tempData = event.Data;
    allData = [allData; tempData];
    timeStamps = [timeStamps; event.TimeStamps];
    disp('test')
    plot(allData)
    
end

