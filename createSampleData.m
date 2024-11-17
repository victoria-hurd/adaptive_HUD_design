% AUTHORS: Victoria Hurd
% DATE: 11/17/24
% PROJECT: HOAV Final Project
% TASK: Create event and display data for HUD adaptive display 

%% Create Display Data
% Display data - each row is a different kind of data to display
% Each column is a time point

% Number of points to simulate - we can keep this at 100 since we
% interpolate to match the number of frames in the video
numpts = 100;

% "time point" is row 1
displayData = 1:numpts;

% Simulate data - these lines will get replaced
% Create first mock display data 
displayData(2,:) = sin(displayData(1,:));
% Create second mock display data 
displayData(3,:) = cos(displayData(1,:));

% Save data
writematrix(displayData,'data/displayData.csv')

%% Create Event Data
% Event data - binary 0 or 1
% % 1 indicates alert, 0 indicates no alert

% "time point" is row 1
eventData(1,:) = 1:numpts;

% Create alert at timepoint 25 - this can get changed
alertFrame = 25;

% Create mock event data - each row is a kind of alert
eventData(2,:) = zeros(1,numpts);
eventData(2,alertFrame) = 1;

% Save data
writematrix(eventData,'data/eventData.csv')

%% Testing Data Displays
% based on number of frames, upsample event data and display data
% We want the number of frames

