function [baseline, df, df_f] = CR_DFOF(downsamp_im)
% Get total frame number and smooth frame;
totalPixel = size(downsamp_im,1);
totalFrame = size(downsamp_im,2);
frameRate = 30;
smoothFrame = 30*frameRate/2; % Smooth over 30 seconds around each sample time point

% Initialization
df = zeros(totalPixel,totalFrame);
df_f = zeros(totalPixel,totalFrame);

% Calculate baseline, df and df_f
for frame = 1:smoothFrame
    baseline(:,frame) = prctile(downsamp_im(:,1:(smoothFrame+frame-1)),10,2);
    df(:,frame) = downsamp_im(:,frame) - prctile(downsamp_im(:,1:(smoothFrame+frame-1)),10,2);
    df_f(:,frame) = df(:,frame)./prctile(downsamp_im(:,1:(smoothFrame+frame-1)),10,2);
    disp(['Frame ' num2str(frame) '/' num2str(totalFrame)]);
end
for frame = (smoothFrame+1):(totalFrame-smoothFrame+1)
    baseline(:,frame) = prctile(downsamp_im(:,(frame-smoothFrame):(frame+smoothFrame-1)),10,2);
    df(:,frame) = downsamp_im(:,frame) - prctile(downsamp_im(:,(frame-smoothFrame):(frame+smoothFrame-1)),10,2);
    df_f(:,frame) = df(:,frame)./prctile(downsamp_im(:,(frame-smoothFrame):(frame+smoothFrame-1)),10,2);
    disp(['Frame ' num2str(frame) '/' num2str(totalFrame)]);
end
for frame = (totalFrame-smoothFrame+2):totalFrame
    baseline(:,frame) = prctile(downsamp_im(:,(frame-smoothFrame):totalFrame),10,2);
    df(:,frame) = downsamp_im(:,frame) - prctile(downsamp_im(:,(frame-smoothFrame):totalFrame),10,2);
    df_f(:,frame) = df(:,frame)./prctile(downsamp_im(:,(frame-smoothFrame):totalFrame),10,2);
    disp(['Frame ' num2str(frame) '/' num2str(totalFrame)]);
end



