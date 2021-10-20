%% Apply transformation matrix
% Also align image frames to a reference bregma after warping to help
% align across animals
% This code uses function WarpImage and AlignWithBregma

clear all
close all
clc

Initial = 'CR';
Animals = {'4383182-O','4383182-L','4383183-O'};

for curr_animal = 1:length(Animals)    
        
    Animal = Animals{curr_animal};
          
    % Get transformation matrix    
    cd(['Z:\Data\' Initial '_' Animal filesep 'WarpedTiff']);
    load([Initial '_' Animal '_WarpedTiff'],'tformSimilarity');
    
    % df/f data folder
    cd(['Z:\Data\' Initial '_' Animal filesep 'df_f']) 
        
    % Get all imaging date folders
    All_file_list = dir(cd);
    Image_folder_list = {All_file_list(cellfun(@(x) ~isempty(strfind(x,'17'))||~isempty(strfind(x,'18'))||~isempty(strfind(x,'21')), {All_file_list.name})).name};
    Image_folder_list = sort(Image_folder_list);
    Im_Session = length(Image_folder_list);
    
    % Reference bregma
    Bregma_Ref = [64,71];
    
    % Load imaging FOV Mask based on the reference image
    load([Image_folder_list{1} filesep Initial '_' Image_folder_list{1} '_' Animal '_01(2).coordinatePixel'], '-mat'); % Bregma
    load([Image_folder_list{1} filesep Initial '_' Image_folder_list{1} '_' Animal '_01(2).pixel'], '-mat'); % mask
    PixelIndex = true(16384,1);
    PixelIndex(roiPixelNum,1) = false;
    
    for curr_session = 1:min(length(IndexInfo),length(Image_folder_list))
        tic
        cd(['Z:\Data\' Initial '_' Animal filesep 'df_f'])
        disp([Initial '_' Animal ' on ' Image_folder_list{curr_session} '...'])        
        % load df_f files
        load([Image_folder_list{curr_session} filesep Initial '_' Image_folder_list{curr_session} '_' Animal '_df_f_all.mat']);
        % Check df_f_all dimention
        Check = length(size(df_f_all));
        if Check == 3
            disp(['Reformating df_f_all on ' Image_folder_list{curr_session} '...'])
            temp_all = df_f_all;
            clear df_f_all;
            for block = 1:size(temp_all,3)
                df_f_all{1,block} = temp_all{block};
            end
        end

        Im_Block = length(df_f_all);       
        for curr_block = 1:Im_Block
            temp_matrix = df_f_all{curr_block};
            temp_matrix_warped = WarpImage(temp_matrix, 128, tformSimilarity{curr_session});
            df_f_all_reg{curr_block} = AlignWithBregma(temp_matrix_warped, coordinate, Bregma_Ref);
            % clear data to save memory
            clear temp_matrix temp_matrix_warped
            df_f_all{curr_block} = [];
        end
        
        % Save
        cd(['Z:\Data\' Initial '_' Animal filesep 'df_f'])
        curr_filename = [Image_folder_list{curr_session} filesep Initial '_' Image_folder_list{curr_session} '_' Animal '_df_f_all_reg.mat'];
        save(curr_filename, 'df_f_all_reg','-v7.3');
        
        toc
    end     
    disp('Finish all imaging sessions! \^o^/')    
end
disp('Finish all animals! \^o^/')

