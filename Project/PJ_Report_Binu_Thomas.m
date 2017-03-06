close all;
clear all;

% Read Video using the vision.VideoFile Reader system object class
videoReader = vision.VideoFileReader('cars_demo_2.mp4'); 

% Create Video Player
videoPlayer = vision.VideoPlayer;
foregroundPlayer = vision.VideoPlayer;

% Create a foregroud detector system object
foregroundDetector = vision.ForegroundDetector('NumGaussians', 3,'NumTrainingFrames', 50);

blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
'AreaOutputPort', false,... 
'CentroidOutputPort', false, ...
'MinimumBlobArea', 150);

% Run on first 100 frames for the foregroundDetector to model the
% background
for i = 1:75
    videoFrame = step(videoReader);
    foreground = step(foregroundDetector,videoFrame);
end

figure;imshow(videoFrame);
title('Input Frame');

figure;imshow(foreground);
title('Foreground');

% Perform open to clean up foreground on the last frame
cleanForeground = imopen(foreground, strel('Disk',1));
figure;

% Display original foreground
subplot(1,2,1);imshow(foreground);title('Original Foreground');

% Display foreground after morphology
subplot(1,2,2);imshow(cleanForeground);title('Clean Foreground');

  
while  ~isDone(videoReader)
    %Get the next frame
    videoFrame = step(videoReader);
    
    %Detect foreground pixels
    foreground = step(foregroundDetector,videoFrame);
   
    % Perform morphological filtering
    cleanForeground = imopen(foreground, strel('Disk',1));
            
    % Detect the connected components with the specified minimum area, and
    % compute their bounding boxes
    bbox = step(blobAnalysis, cleanForeground);

    % Draw bounding boxes around the detected cars
    %result = insertShape(videoFrame, 'Rectangle', bbox, 'Color', 'green');
    
    result = insertObjectAnnotation(videoFrame, 'rectangle', bbox, 'car');

    % Display the number of cars found in the video frame
    num_cars = size(bbox, 1);
    text = sprintf('Detected Vehicles = %d',num_cars);
    
    result = insertText(result, [10 10], num_cars, 'BoxOpacity', 1, ...
        'FontSize', 14);

    % Display output 
    step(videoPlayer, result);
    step(foregroundPlayer,cleanForeground);
end

% Release memory
release(videoReader);
release(videoPlayer);
    
    
