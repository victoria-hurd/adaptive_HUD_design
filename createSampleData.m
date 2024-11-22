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

%% Create Event Data
% Event data - binary 0 or 1
% % 1 indicates alert, 0 indicates no alert
% Alerts should stay for 15 frames
alertDuration = 15;
% Zeros for [number of types of alerts, frames of HUDfootage]
eventData(2,:) = zeros(1,numpts);

% Create data matrix
% Row 1: Frame/"time point"
eventData(1,:) = 1:numpts;
% Row 2: Suit Leak/Hypoxia Alert
% Create alert at frame 25 - this can get changed
alertFrame = 25;
eventData(2,alertFrame:alertFrame+alertDuration) = 1;

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
plot(displayData(6,:)); xlabel('Frame'); ylabel('HR'); title('Simulated HR per Frame')
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
plot(displayData(7,:)); xlabel('Frame'); ylabel('RR'); title('Simulated RR per Frame')
% Finally, round to nearest integer
displayData(7,:) = floor(displayData(7,:));

% Row 8: O2 Consumption Rate. Nominal is 0.1 psi/min
displayData(8,:) = round(0.1+0.015*randn(1,numpts), 1);

% Row 9: Cognitive Load. Nominal is 0, abnormal is 1
displayData(9,:) = zeros(1,numpts);

% Row 10: Compass Data. Hard-coded to match video 

% Row 11: Distance to LEM. Hard-coded to match minimap

% Row 12: Distance to ROI1. Hard-coded to match minimap

% Row 13: EVA Task Instructions. Hard-coded to match video/minimap

% Save data
writematrix(displayData,'data/displayDataNominal.csv')

%% Create Suit Leak/hypoxia data
% Use nominal display data as base. Upon hypoxia alert frame, change data
displayDataSuitLeak = displayData;

% Save data
writematrix(displayDataSuitLeak,'data/displayDataSuitLeak.csv')