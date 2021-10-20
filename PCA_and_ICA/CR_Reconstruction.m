%% Reconstruction using ICs

clear all
close all
clc

Initial = 'CR';
Animals = {'4383182-O','4383182-L','4383183-O'};

for curr_animal = 1:length(Animals)
    
    clearvars -except Initial Animals curr_animal
    
    Animal = Animals{curr_animal};
    disp(Animal);
    
    CompNum = 40;
    cd(['Z:\Data\' Initial '_' Animal filesep 'EventAligned_Gap500']);
    % Retained mode for cortical modules
    load([Initial '_' Animal '_RecICA_' num2str(CompNum)],'Mode_Selected','sortMode_Retained','-mat');
    cd(['Z:\Data\' Initial '_' Animal '\EventAligned_Gap500\ICA\ICA_' num2str(CompNum)]);
    load([Initial '_' Animal '_ICA_AllSession.mat']);
    
    % Reconstruction
    RecICA_Sum = ModeICA(:,Mode_Selected)*SCORE_ICA_all(Mode_Selected,:) + repmat(Temporal_Mean_allsession,1,size(SCORE_ICA_all,2));
    
    % Organize reconstructed image frames into event epochs
    fields = fieldnames(FrameNumPerSession);
    for field = 1:length(fields)
        temp_FrameNum = FrameNumPerSession.(fields{field});
        temp_FrameNum = temp_FrameNum(~isnan(temp_FrameNum));
        total_num = sum(temp_FrameNum);
        temp = RecICA_Sum(:,1:total_num);
        if strcmp('CueAligned',fields{field})
            RecICA_Cue = mat2cell(temp', temp_FrameNum)';
            RecICA_Cue = cellfun(@transpose,RecICA_Cue,'UniformOutput',false);
            RecICA_Sum(:,1:total_num) = [];
            clear temp
        elseif strcmp('MovOnsetAligned',fields{field})
            RecICA_Mov = mat2cell(temp', temp_FrameNum)';
            RecICA_Mov = cellfun(@transpose,RecICA_Mov,'UniformOutput',false);
            RecICA_Sum(:,1:total_num) = [];
            clear temp
        elseif strcmp('RewardAligned',fields{field})
            RecICA_Reward = mat2cell(temp', temp_FrameNum)';
            RecICA_Reward = cellfun(@transpose,RecICA_Reward,'UniformOutput',false);
            RecICA_Sum(:,1:total_num) = [];
            clear temp
        end
    end
    
    cd(['Z:\Data\' Initial '_' Animal filesep 'EventAligned_Gap500']);
    disp('Saving...');
    save([Initial '_' Animal '_RecICA_' num2str(CompNum)],'RecICA_Cue','RecICA_Mov','RecICA_Reward','-append');
    
    clear RecICA_Cue RecICA_Reward RecICA_Sum
end
  