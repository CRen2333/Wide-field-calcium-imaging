%% *** Curent coding is based on Hiroshi's coding ***
%% *** Passed test 10252015 by CR ***

%% Clear
clear all;
close all;
clc;

%% Load image file

Initial = 'CR';
Animal = '4383183-O';
Date = '210905';

% Organize the files by animal or date
tiff_path = ['C:\Data\' Date filesep Initial '_' Animal]; % Change to actual folder

cd(tiff_path)
% Make sure the folder only contains raw tiff images
tiff_filename_all = dir('*.tif');
tiff_filename_all = {tiff_filename_all.name};

%% Downsample
% The code is for alternating imaging design at 30 Hz with 5-min on (9000 frames) and 5-min off.
% During importing from dcimage to tiff file format, HCImageLive save every
% 8180 frames to a single tiff file. Therefore, each 5-min imaging block
% correspond to 2 tiff files
for block = 1:(length(tiff_filename_all)/2)
    
    % Create tempopary variable for the following loops
    tiff_filename = {tiff_filename_all{(block*2-1):(block*2)}};
    
    % Initialize concatenated matrix with total number of frames in current block
    total_numframes = 0;
    for ii = 1:length(tiff_filename)
        img_filename{ii} = [tiff_path filesep tiff_filename{ii}];
        imageinfo{ii} = [];
        imageinfo{ii} = imfinfo([img_filename{ii}],'tiff');
        numframes(ii) = length(imageinfo{ii});
    end
    total_numframes = sum(numframes);
    disp(['Total frames: ' num2str(total_numframes)]);
    
    % initialize
    curr_frame = 1; 
    downsamp_im = [];
    for ii = 1:length(tiff_filename)
        im_temp = [];
        disp('Loading file....')
        for loadframe = 1:numframes(ii)
            im_temp = imread([img_filename{ii}],'tiff',loadframe,'Info',imageinfo{ii}); % 512*512
            
            % ----- Only for Downsample ----- %
            im_temp_double = double(im_temp);
            resized_im_temp_double = imresize(im_temp_double,0.25);
            downsamp_im(:,curr_frame) = reshape(resized_im_temp_double,16384,1); % 128*128
            
            curr_frame = curr_frame+1;
            disp(['Frame ' num2str(loadframe) '/' num2str(numframes(ii))]);
        end
    end
    downsamp_im_allsession(:,:,block) = downsamp_im; % Organize by pixel*frame*block
end

% save
[curr_file, errmsg] = sprintf([Initial '_' Animal '_downsamp_im_allsession']);
save(curr_file,'downsamp_im_allsession','-v7.3')

