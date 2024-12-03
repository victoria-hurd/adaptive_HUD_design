% AUTHORS: Victoria Hurd
% DATE: 11/17/24
% PROJECT: HOAV Final Project
% TASK: Create event and display data for HUD adaptive display 

%% Setup
% Number of points to simulate - keep this at 2617. This is the number of
% frames in HUDFootage
numpts = 2617;
fps = 59.94;
stopSec = 23; % When we stop moving in HUD footage - hardcoded
stopFrame = round(stopSec*fps);
% Hard-coded times: at 10 sec closest to LEM. Stable for 3 sec. Moving away
% from LEM up to 23 sec. Stable to end of video
DistIncrements = [round(fps*[10,10+3,23]) numpts];
% Hard-coded times: based on rotations in HUDFootage
% Rotations go W, WtoN, NtoE, E, EtoN, N, NtoE, E, EtoN, N, NtoE
RotIncs = [round(fps*[2,4,6,9,11,13,16,20,24,29,41]) numpts];
% Task Increments
taskIncs = [round(fps*[10,13,23,26,35]) numpts];

%% Create Event Data
% Event data - binary 0 or 1
% % 1 indicates alert, 0 indicates no alert
% Alerts should stay for 15 frames
alertDuration = 50;
% Zeros for [number of types of alerts, frames of HUDfootage]
eventData(2,:) = zeros(1,numpts);
eventData(3,:) = zeros(1,numpts);
eventData(4,:) = zeros(1,numpts);

% Create data matrix
% Row 1: Frame/"time point"
eventData(1,:) = 1:numpts;
% Row 2: Suit Leak/Hypoxia Alert
% Create alert at frame 1800
alertFrame_hypox = 100;
eventData(2,alertFrame_hypox:alertFrame_hypox+alertDuration) = 1;

% Row 3: Excessive Workload Alert
alertFrame_work = 20;
eventData(3,alertFrame_work:alertFrame_work+alertDuration) = 1;

% Row 4: Low battery Alert
alertFrame_batt = 200;
eventData(4,alertFrame_batt:alertFrame_batt+alertDuration) = 1;


% Save data
writematrix(eventData,'data/eventData.csv')

%% Create Nominal Display Data
% Display data - each row is a different kind of data to display
% Each column is a time point

% Number of points to simulate - keep this at 2617. This is the number of
% frames in HUDFootage
numpts = 2617;

% Row 1: frame/"time point"
displayData = 1:numpts;

% Simulate data
% Row 2: Oxygen Levels from 0 to 1. Nominal is slow, constant decrease
% Go from 95% to 75%
displayData(2,:) = linspace(95,75,numpts);

% Row 3: CO2 Scrubber Status. Binary 0 or 1, Nominal is 1
displayData(3,:) = ones(1,numpts);

% Row 4: Suit Operating Pressure. Nominal 4.3psi. Round to 1 dec place
% Use mean of 4.3psi, std of 0.05 psi
%step1Result = mean + std * randn(1,numpts);
displayData(4,:) = round(4.3+0.05*randn(1,numpts), 1);

% Row 5: Remaining Battery life. Nominal is slow, constant decrease
% Go from 85% to 60%
displayData(5,:) = round(linspace(85,60,numpts));

% Row 6: Heart Rate. Nominal is between 90 and 130. 
% While moving, keep HR high. After stopping, make lower. 
% Moving mean: 120+/-10std. Stopped mean: 100+/-10std
displayData(6,:) = zeros(1,numpts);
displayData(6,1:stopFrame) = round(120+10*randn(1,length(1:stopFrame)));
displayData(6,stopFrame+1:end) = round(100+10*randn(1,numpts-length(1:stopFrame)));
% We need to smooth this data now. From: https://www.mathworks.com/matlabcentral/answers/1830828-how-to-create-a-random-and-smooth-varying-rpm-profile
% filter the vector
fs = fps;
ft = 0.25; % this scales the filter width
R = floor((ceil((ft*fs*5-1)/2)*2+1)/2); % this is always even
x = -R:R; % so this is always of odd length
fk = exp(-(x/(1.414*ft*fs)).^2); % a 1-D gaussian
displayData(6,:) = conv(displayData(6,:),fk,'same'); % apply LPF
% scale/translate the vector
HRrange = [90 130];
HRrange0 = [min(displayData(6,:)) max(displayData(6,:))];
displayData(6,:) = (displayData(6,:)-HRrange0(1))/range(HRrange0); % normalize
displayData(6,:) = displayData(6,:)*range(HRrange) + HRrange(1); % rescale
%plot(displayData(6,:)); xlabel('Frame'); ylabel('HR'); title('Simulated HR per Frame')
% Finally, round to nearest integer
displayData(6,:) = round(displayData(6,:));

% Row 7: Respiration Rate. 12 to 20 is normal
% Use same method as row 6
% Let mean be 15 brpm, std of 5
displayData(7,:) = 15+5*randn(1,numpts);
fs = fps;
ft = 0.5; % this scales the filter width
R = floor((ceil((ft*fs*5-1)/2)*2+1)/2); % this is always even
x = -R:R; % so this is always of odd length
fk = exp(-(x/(1.414*ft*fs)).^2); % a 1-D gaussian
displayData(7,:) = conv(displayData(7,:),fk,'same'); % apply LPF
% scale/translate the vector
RRrange = [12 17];
RRrange0 = [min(displayData(7,:)) max(displayData(7,:))];
displayData(7,:) = (displayData(7,:)-RRrange0(1))/range(RRrange0); % normalize
displayData(7,:) = displayData(7,:)*range(RRrange) + RRrange(1); % rescale
%plot(displayData(7,:)); xlabel('Frame'); ylabel('RR'); title('Simulated RR per Frame');
% Finally, round to nearest integer
displayData(7,:) = floor(displayData(7,:));

% Row 8: O2 Consumption Rate. Nominal is 0.1 psi/min
displayData(8,:) = round(0.1+0.015*randn(1,numpts), 1);

% Row 9: Cognitive Load. Nominal is 0, abnormal is 1
displayData(9,:) = zeros(1,numpts);

% Row 10: Compass Data. Hard-coded to match video 
displayData(10,:) = zeros(1,numpts);
% 90 is North, 180 is West, 270 is S, 0 is E
north = 90; west = 180; east = 0;
displayData(10,1:RotIncs(1)) = linspace(west,west,RotIncs(1)); % W
displayData(10,RotIncs(1)+1:RotIncs(2)) = linspace(west,north,RotIncs(2)-RotIncs(1)); % W to N
displayData(10,RotIncs(2)+1:RotIncs(3)) = linspace(north,north,RotIncs(3)-RotIncs(2)); % N 
displayData(10,RotIncs(3)+1:RotIncs(4)) = linspace(north,east,RotIncs(4)-RotIncs(3)); % N to E
displayData(10,RotIncs(4)+1:RotIncs(5)) = linspace(east,east,RotIncs(5)-RotIncs(4)); % E
displayData(10,RotIncs(5)+1:RotIncs(6)) = linspace(east,north,RotIncs(6)-RotIncs(5)); % E to N
displayData(10,RotIncs(6)+1:RotIncs(7)) = linspace(north,north,RotIncs(7)-RotIncs(6)); % N
displayData(10,RotIncs(7)+1:RotIncs(8)) = linspace(north,east,RotIncs(8)-RotIncs(7)); % N to E
displayData(10,RotIncs(8)+1:RotIncs(9)) = linspace(east,east,RotIncs(9)-RotIncs(8)); % E
displayData(10,RotIncs(9)+1:RotIncs(10)) = linspace(east,north,RotIncs(10)-RotIncs(9)); % E to N
displayData(10,RotIncs(10)+1:RotIncs(11)) = linspace(north,north,RotIncs(11)-RotIncs(10)); % N
displayData(10,RotIncs(11)+1:RotIncs(12)) = linspace(north,east,RotIncs(12)-RotIncs(11)); % N to E
%plot(displayData(10,:))

% Row 11: Distance to LEM. Hard-coded to match minimap
displayData(11,:) = zeros(1,numpts);
% Assume start 35 m from LEM, end 5m from LEM
displayData(11,1:DistIncrements(1)) = linspace(25,5,DistIncrements(1));
% Stable for 3 seconds
displayData(11,DistIncrements(1)+1:DistIncrements(2)) = linspace(5,5,DistIncrements(2)-DistIncrements(1));
% Move away until 23 seconds. Go from 5m to 20m at ROI1
displayData(11,DistIncrements(2)+1:DistIncrements(3)) = linspace(5,20,DistIncrements(3)-DistIncrements(2));
% Stable until end
displayData(11,DistIncrements(3)+1:DistIncrements(4)) = linspace(20,20,DistIncrements(4)-DistIncrements(3));
displayData(11,:) = round(displayData(11,:),1);
%plot(displayData(11,:))

% Row 12: Distance to ROI1. Hard-coded to match minimap
displayData(12,:) = zeros(1,numpts);
% Assume start 40 m from ROI1, end 13m from ROI1
displayData(12,1:DistIncrements(1)) = linspace(40,17,DistIncrements(1));
% Stable for 3 seconds
displayData(12,DistIncrements(1)+1:DistIncrements(2)) = linspace(17,17,DistIncrements(2)-DistIncrements(1));
% Move away until 23 seconds. Go from 13m to 0m at ROI1
displayData(12,DistIncrements(2)+1:DistIncrements(3)) = linspace(17,0,DistIncrements(3)-DistIncrements(2));
% Stable until end
displayData(12,DistIncrements(3)+1:DistIncrements(4)) = linspace(0,0,DistIncrements(4)-DistIncrements(3));
displayData(12,:) = round(displayData(12,:),1);
% plot(displayData(12,:))

% EVA Task Instructions. Hard-coded to match video/minimap
evaInstructions(1,numpts) = "NA";
evaInstructions(1,1:taskIncs(1)) = "Proceed to LEM";
evaInstructions(1,taskIncs(1):taskIncs(2)) = strcat(evaInstructions(taskIncs(1))," Gather Supplies");
evaInstructions(1,taskIncs(2):taskIncs(3)) = strcat(evaInstructions(taskIncs(2))," Proceed to ROI 1");
evaInstructions(1,taskIncs(3):taskIncs(4)) = strcat(evaInstructions(taskIncs(3))," Identify Sample");
evaInstructions(1,taskIncs(4):taskIncs(5)) = strcat(evaInstructions(taskIncs(4))," Drill Sample");
evaInstructions(1,taskIncs(5):taskIncs(6)) = strcat(evaInstructions(taskIncs(5))," Return to LEM");

% Save data
% writematrix(displayData,'data/displayDataNominal.csv')
writematrix(evaInstructions,'data/evaInstructions.csv')

%% Create Suit Leak/hypoxia data
% Use nominal display data as base. Upon hypoxia alert frame, change data
displayDataSuitLeak = displayData;

% Oxygen levels go from 60 to 40)
displayDataSuitLeak(2,alertFrame_hypox:alertFrame_hypox+alertDuration-1) = linspace(60,40,alertDuration);

% Suit operating pressure goes down to 2.1 psi
displayDataSuitLeak(4,alertFrame_hypox:alertFrame_hypox+alertDuration-1) = linspace(3.6, 2.1, alertDuration);

% CO2 Scrubber status goes to 0
displayDataSuitLeak(3,alertFrame_hypox:alertFrame_hypox+alertDuration) = 0;

% Heart Rate increases
displayDataSuitLeak(6,alertFrame_hypox:alertFrame_hypox+alertDuration-1) = linspace(130,150,alertDuration);

% Respiration rate increases
displayDataSuitLeak(7,alertFrame_hypox:alertFrame_hypox+alertDuration-1) = linspace(20,35,alertDuration);

% Cognitive Load increases
displayDataSuitLeak(9,alertFrame_hypox:alertFrame_hypox+alertDuration-1) = 1;

% Save data
% writematrix(displayDataSuitLeak,'data/displayDataSuitLeak.csv')

%% Create Overexertion Event
% Use nominal display data as base. Upon excessive workload alert frame, change data
displayDataWorkload = displayDataSuitLeak;

% Heart rate increases and then decreases back to nom conditions
displayDataWorkload(6,alertFrame_work:alertFrame_work+alertDuration/2) = linspace(120, 175, (alertDuration/2)+1);
displayDataWorkload(6,alertFrame_work+alertDuration/2:alertFrame_work+alertDuration) = linspace(175, 120, (alertDuration/2)+1);

% O2 consumption rate increases and then decreases back to nom conditions
displayDataWorkload(8,alertFrame_work:alertFrame_work+alertDuration/2) = linspace(.18, .5, (alertDuration/2)+1);
displayDataWorkload(8,alertFrame_work+alertDuration/2:alertFrame_work+alertDuration) = linspace(.5, .1, (alertDuration/2)+1);

% Respiration rate increases and then decreases back to nom conditions
displayDataWorkload(7,alertFrame_work:alertFrame_work+alertDuration/2) = linspace(25, 40, (alertDuration/2)+1);
displayDataWorkload(7,alertFrame_work+alertDuration/2:alertFrame_work+alertDuration) = linspace(40, 20, (alertDuration/2)+1);

% Save data
writematrix(displayDataWorkload,'data/displayDataWorkload.csv')

%% Create Low Battery Event
% Use nominal display data as base. Upon excessive workload alert frame, change data
displayDataBattery = displayDataWorkload;

% Battery reduces!
displayDataBattery(5,alertFrame_batt:alertFrame_batt+alertDuration-1) = linspace(40,25,alertDuration);



% Save data
writematrix(displayDataBattery,'data/displayDataAllAlerts.csv')

% Make alterations to the nominal data - 
% For example: displayData(3,alertFrame:alertFrame+alertDuration) = 0;
% ^ this would cause an alarm for CO2 scrubber turned off (set to 0) at
% frame 25 until frame 40

% We can do this for whatever makes sense for each event! I think a suit
% leak one would be cool - oxygen dips fast, HR goes up, pressure down, etc
% ^ this would be like a hypoxia scenario


