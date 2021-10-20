%% *** Curent coding is based on Hiroshi's coding and Takaki's suggestion***
%% *** Passed test 11112015 by CR ***
% Use this code together with function CR_DFOF

%% Clear
clear all;
close all;
clc;

% Load downsampled data
Initial = 'CR';
Animal = '4383183-O';
Date = '210905';

cd(['C:\Data\' Date filesep Initial '_' Animal]);

disp('Loading Downsample file...')
load([Initial '_' Animal '_downsamp_im_allsession']);   

% Remove slow timescale changes (e.g. photobleaching)
frameRate = 30; 
totalPixel = size(downsamp_im_allsession,1);
totalFrame = size(downsamp_im_allsession,2);
totalBlock = size(downsamp_im_allsession,3);
smoothFrame = 30*frameRate/2; % Smooth over 30 seconds around each sample time point

% Transfer domsample_im from array to cell
downsamp_im_all = mat2cell(downsamp_im_allsession,[totalPixel],[totalFrame],ones(1,totalBlock));

% Check if df_f is halfway through
All_filelist = dir(cd);
All_filename = {All_filelist.name};
Check = cellfun(@(x) strfind(x,'df_f_all'), All_filename, 'UniformOutput', false);
Check = cell2mat(Check); %%%%% CR Changed 11162015 %%%%%

if isempty(Check) % df_f hasn't been started yet %%%%% CR Changed 11162015 %%%%%
    % Initialization
    baseline_all = {};
    df_all = {};
    df_f_all = {};
    % Timing
    tic
    % Get baseline, df, df_f
    for block = 1:totalBlock
        disp(['Calculating imaging block ' num2str(block)]);
        % Initialization
        temp_baseline = [];
        temp_df = [];
        temp_df_f = [];
        % Calculation
        [temp_baseline, temp_df, temp_df_f] = CR_DFOF(downsamp_im_all{block});
        baseline_all{block} = temp_baseline;
        df_all{block} = temp_df;
        df_f_all{block} = temp_df_f;

        % Saving every block
        disp(['Saving block ' num2str(block) ' ...']);

        save([Initial '_' Date '_' Animal '_baseline_all'],'baseline_all','-v7.3') % HM modified
        save([Initial '_' Date '_' Animal '_df_all'],'df_all','-v7.3') % HM modified
        save([Initial '_' Date '_' Animal '_df_f_all'],'df_f_all','-v7.3') % HM modified
        
        disp('Saving block done.');
    end
    % Timing
    Timing = toc/60;
    disp(['Use' num2str(Timing) 'min.'])
    disp('All blocks done.');

else % df_f has been started
    load([Initial '_' Date '_' Animal '_df_f_all'],'df_f_all'); % HM modified
    % Check whether df_f has been finished
    if length(df_f_all) == totalBlock % All blocks are finished
        disp('All blocks done.');
    else
        % Check whether current folder also contains beseline_all and df_all
        Check_baseline = cellfun(@(x) strfind(x,'baseline_all'), All_filename, 'UniformOutput', false);
        Check_df = cellfun(@(x) strfind(x,'df_all'), All_filename, 'UniformOutput', false);
        if ~isempty(Check_baseline) % if beseline_all exists
            load([Initial '_' Date '_' Animal '_baseline_all'],'baseline_all'); % HM modified
        end
        if ~isempty(Check_df) % if df_all exists
            load([Initial '_' Date '_' Animal '_df_all'],'df_all'); % HM modified
        end
        % Continue
        curr_block = length(df_f_all)+1;
        disp(['Continue from imageing block' num2str(curr_block)]);
        % Timing
        tic
        % Get baseline, df, df_f
        for block = curr_block:totalBlock
            disp(['Calculating imaging block ' num2str(block)]);
            % Initialization
            temp_baseline = [];
            temp_df = [];
            temp_df_f = [];
            % Calculation
            [temp_baseline, temp_df, temp_df_f] = CR_DFOF(downsamp_im_all{block});
            baseline_all{block} = temp_baseline;
            df_all{block} = temp_df;
            df_f_all{block} = temp_df_f;

            % Saving Current block
            disp(['Saving block ' num2str(block) ' ...']);
            save([Initial '_' Date '_' Animal '_baseline_all'],'baseline_all','-v7.3') % HM modified
            save([Initial '_' Date '_' Animal '_df_all'],'df_all','-v7.3') % HM modified
            save([Initial '_' Date '_' Animal '_df_f_all'],'df_f_all','-v7.3') % HM modified
            disp('Saving block done.');
        end
        % Timing
        Timing = toc/60;
        disp(['Use' num2str(Timing) 'min.'])
        disp('All blocks done.');
    end
end
