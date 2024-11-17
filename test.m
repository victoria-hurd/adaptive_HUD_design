% testing code to go into the app

% reading in our display and event data
displayData = readmatrix("data/displayData.csv");
eventData = readmatrix("data/eventData.csv");

% plotting per frame
% need some indicator of what frame we're on
filename = 'data/HUDFootage.mp4';
v = VideoReader(filename);
frame = readFrame(v);
im_frame = imshow(frame);

while hasFrame(v)
    im_frame.CData = readFrame(v);
    drawnow

    currentFrame = v.CurrentTime*v.FrameRate;
    disp(displayData(2,round(currentFrame)))
    
end

