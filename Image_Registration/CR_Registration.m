%% Image registration across imaging sessions within individual animals

clear all
close all
clc

Initial = 'CR';
Animals = {'4383182-O','4383182-L','4383183-O'};

for curr_animal = 1:length(Animals)
    clear Tiff_Ave Tiff_Ave_Resize tformSimilarity movingRegisteredSmilarity
    Animal = Animals{curr_animal};
    disp(Animal);

    % Data folder
    cd(['Z:\Data\' Initial '_' Animal filesep 'df_f']) 
    
    All_file_list = dir(cd);
    Image_folder_list = {All_file_list(cellfun(@(x) ~isempty(strfind(x,'17'))||~isempty(strfind(x,'18'))||~isempty(strfind(x,'19'))||~isempty(strfind(x,'21')), {All_file_list.name})).name};
    Image_folder_list = sort(Image_folder_list);

    for curr_session = 1:length(Image_folder_list)
        Date = Image_folder_list{curr_session};
        disp(Date);
        tic
        data_path = ['Z:\Data\' Initial '_' Animal filesep 'df_f' filesep Date];        
        fname = [data_path filesep Initial '_' Date '_' Animal '_01(2).tif'];
        localfname = ['C:\Lab\Projects\Temp' filesep filesep Initial '_' Date '_' Animal '_01(2).tif'];
        copyfile(fname,localfname);
        info = imfinfo(localfname,'tiff');
        numframes = length(info);
        for kk = 1:numframes
            disp([num2str(kk) '/' num2str(numframes)]);
            temp_image(:,:,kk) = imread([fname],'tiff',kk,'Info',info);
        end
        Tiff_Ave(:,:,curr_session) = nanmean(temp_image,3);
        Tiff_Ave_Resize(:,:,curr_session) = imresize(Tiff_Ave(:,:,curr_session),0.25);
        clear temp_image
        delete(localfname);
        toc
    end
    
    for curr_session = 1:length(Image_folder_list)
        
        fixed = Tiff_Ave_Resize(:,:,1); % or 5 when habituated
        moving = Tiff_Ave_Resize(:,:,curr_session);
        % Get transforming matrix
        [optimizer, metric] = imregconfig('multimodal');
        tformSimilarity{curr_session} = imregtform(moving,fixed,'similarity',optimizer,metric);
        Rfixed = imref2d(size(fixed));
        movingRegisteredSmilarity(:,:,curr_session) = imwarp(moving,tformSimilarity{curr_session},'OutputView',Rfixed);
    
    end
    
    cd(['Z:\Data\' Initial '_' Animal]);
    mkdir('WarpedTiff'); cd('WarpedTiff');
    figure;
    hold on;
    for curr_session = 1:length(Image_folder_list)
        subplot(4,5,curr_session);
        imshowpair(movingRegisteredSmilarity(:,:,curr_session),fixed,'diff','Scaling','independent');
    end
    saveas(gcf,[Initial '_' Animal '_Warped.fig']);
    close all;
    save([Initial '_' Animal '_WarpedTiff'],'Tiff_Ave','Tiff_Ave_Resize','tformSimilarity','movingRegisteredSmilarity','-v7.3');        
end   
    

