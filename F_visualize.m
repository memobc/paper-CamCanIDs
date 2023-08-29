% Run the CamCan Individual Differences Analyses

%% requirements

% All directories are defined relative to the location of this script. See
% mfilename and fileparts help pages for more details
rootDir  = fileparts(mfilename('fullpath'));

% All software (spm12, conn, CoSMo) have symbolic links in the code
% directory.
spm12Dir = fullfile(rootDir, 'spm12');
connDir  = fullfile(rootDir, 'conn');
cosmoDir = fullfile(rootDir, 'cosmo');
atlasDir = fullfile(rootDir, 'atlas');
addpath(spm12Dir, connDir, genpath(cosmoDir));

%% concatenate and calculate connectivity

load('results/ConnTbl_gsr.mat')

ROIdir     = fullfile(atlasDir, 'Parcellations', 'MNI', 'Centroid_coordinates');
ROIfile    = fullfile(ROIdir, 'Schaefer2018_400Parcels_17Networks_order_FSLMNI152_2mm.Centroid_RAS.csv');
ROITbl     = load_roi_information(ROIfile);

% Figure out sensible tick labels
hems  = unique(ROITbl.hemisphere);
nets  = unique(ROITbl.network);
ticks = nan(1, length(hems)*length(nets));
linesPos  = ticks;
tickLabel = cell(1, length(hems)*length(nets));
c = 0;
for h = 1:length(hems)
    this_hem = strcmp(ROITbl.hemisphere, hems{h});
    for n = 1:length(nets)
        c = c+1;
        this_net = strcmp(ROITbl.network, nets{n});
        idx = find(this_hem & this_net);
        ticks(c) = median(idx);
        tickLabel{c} = nets{n};
        linesPos(c)  = max(idx);        
    end
end

[ticks, I] = sort(ticks);
tickLabel  = tickLabel(I);
linesPos = linesPos + 0.5;
linesPos(end) = [];

% Create Figures

AllConnMats = cat(3, ConnTbl.intrinsic{:});

%% Full Group Level Connectivity Matrix

GrandConnMat = mean(AllConnMats, 3);

figure;
imagesc(GrandConnMat, [-.5 .5]);
colorbar;
title('Mean Connectivity Matrix', 'Position', [200 -40])
subtitle('Whole Brain')
ax = gca;
ylabel('Network')
ax.XTick = ticks;
ax.YTick = ticks;
ax.XTickLabel = tickLabel;
ax.YTickLabel = tickLabel;
ax.TickLength = [0 0];
ax.XTickLabelRotation = 90;
yyaxis('right')
ax = gca;
ax.YTick = [.25 .75];
ax.YTickLabel = {'Right', 'Left'};
ylabel('Hemisphere')

% can we downsample the Grand Conn Mat?

% downsample to network/hemisphere
nets = ROITbl(:,{'network', 'hemisphere'});
nets = unique(nets);
netsHem_connectome = nan(height(nets), height(nets));
for r = 1:height(nets)
    rF = strcmp(ROITbl.network, nets.network{r}) & strcmp(ROITbl.hemisphere, nets.hemisphere{r});
    for c = 1:height(nets)
        cF = strcmp(ROITbl.network, nets.network{c}) & strcmp(ROITbl.hemisphere, nets.hemisphere{c});
        thisCombo = GrandConnMat(rF, cF);
        if c == r
            thisCombo = tril(thisCombo, -1);
            thisCombo(thisCombo == 0) = NaN;
            netsHem_connectome(r,c) = mean(thisCombo, 'all', 'omitnan');
        else
            netsHem_connectome(r,c) = mean(thisCombo, 'all');
        end
    end
end

% 
unique_nets = unique(nets.network);
nets_connectome = nan(length(unique_nets), length(unique_nets));
for r = 1:length(unique_nets)
    rF = strcmp(nets.network, unique_nets{r});
    for c = 1:length(unique_nets)
        cF = strcmp(nets.network, unique_nets{c});
        thisCombo = netsHem_connectome(rF, cF);
        nets_connectome(r,c) = mean(thisCombo, 'all');
    end
end

figure;
imagesc(nets_connectome); colorbar;
ax = gca;
ax.XTick = 1:18;
ax.YTick = 1:18;
ax.XTickLabel = unique_nets;
ax.YTickLabel = unique_nets;
ax.XTickLabelRotation = 90;
writematrix(nets_connectome, 'downsampled_grand_connectome.txt');
writecell(unique_nets, 'gradmean_networks.txt');

% What is the distribution of connectivity values?
LowerTriangle = tril(GrandConnMat, -1);
LowerTriangle(LowerTriangle == 0) = NaN;
AllValues = LowerTriangle(:);
AllValues(isnan(AllValues)) = [];
figure;
histogram(AllValues)
title('Distribution of Mean Connectivity Values')
subtitle('In the Whole Brain Mean Connectivity Matrix')
xlabel('Mean Strength of Connection Across Subjects (r)')
ylabel('Number of Connections')

%% Zooming in on the hippocampus

HIPP_F = contains(ROITbl.network, 'Subcortical');

figure;
imagesc(GrandConnMat(:, HIPP_F), [-.5, .5]);
colorbar();

yticks(ticks);
yticklabels(tickLabel);
xticks(1:6);
xticklabels({'HIPP.BODY.L'; 'HIPP.BODY.R'; 'HIPP.HEAD.L'; 'HIPP.HEAD.R'; 'HIPP.TAIL.L'; 'HIPP.TAIL.R'});
xtickangle(90);
for l = linesPos
    %xline(l, 'LineWidth', 1.5);
    %yline(l, 'LineWidth', 1.5);
end
ylabel('Network')
yyaxis('right')
yticks([.25, .75])
yticklabels({'Right', 'Left'})
ylabel('hemisphere')
title('Mean Connectivity Matrix')
subtitle('Default Mode Subnetworks')

LowerTriangle = tril(GrandConnMat, -1);
LowerTriangle(LowerTriangle == 0) = NaN;
LowerTriangle = LowerTriangle(HIPP_F, :);
AllValues = LowerTriangle(:);
AllValues(isnan(AllValues)) = [];
figure;
histogram(AllValues)
title('Distribution of Mean Connectivity Values')
subtitle('Only Hippocampal Connections')
xlabel('Mean Strength of Connection Across Subjects (r)')
ylabel('Number of Connections')

keyboard

%% std dev 
GrandStdMat = std(AllConnMats, 1, 3);
addpath(connDir);
addpath(genpath(cosmoDir));
HIPP_F = contains(ROITbl.network, 'Default');
ROITbl_filt = ROITbl(HIPP_F,:);

% find sensible tick labels
hems  = unique(ROITbl_filt.hemisphere);
nets  = unique(ROITbl_filt.network);
ticks = nan(1, length(hems)*length(nets));
linesPos  = ticks;
tickLabel = cell(1, length(hems)*length(nets));
c = 0;
for h = 1:length(hems)
    this_hem = strcmp(ROITbl_filt.hemisphere, hems{h});
    for n = 1:length(nets)
        c = c+1;
        this_net     = strcmp(ROITbl_filt.network, nets{n});
        idx          = find(this_hem & this_net);
        ticks(c)     = median(idx);
        linesPos(c)  = max(idx);
        tickLabel{c} = nets{n};
    end
end

[ticks, I] = sort(ticks);
tickLabel  = tickLabel(I);
linesPos = linesPos + 0.5;
linePos(end) = [];

figure;
imagesc(GrandStdMat(HIPP_F, HIPP_F));
colorbar;
xticks(ticks);
xticklabels(tickLabel);
yticks(ticks);
yticklabels(tickLabel);
xtickangle(90);
for l = fitlm
    xline(l, 'LineWidth', 1.5);
    yline(l, 'LineWidth', 1.5);
end
ylabel('Network')
yyaxis('right')
yticks([.25, .75])
yticklabels({'Right', 'Left'})
ylabel('hemisphere')
title('Deviation Connectivity Matrix')
subtitle('Default Mode Subnetworks')

%% An exploration of variability

% What is the most variable connection in the DMN conn matrix?
DMN_StdMat = GrandStdMat(HIPP_F, HIPP_F);
DMN_AllConnMat = AllConnMats(HIPP_F, HIPP_F, :);

[M,I] = max(DMN_StdMat, [], 'all', 'linear');
[X,Y] = ind2sub(size(DMN_StdMat), I);

figure;
histogram(squeeze(DMN_AllConnMat(X,Y,:)))
title(sprintf('Most Variable Connection (std = %f)', M))
subtitle(sprintf('Connection %s --- %s', ...
    strrep(ROITbl_filt.ROIName{X}, '_', '-'), ...
    strrep(ROITbl_filt.ROIName{Y}, '_', '-')))
xlabel('Connection Strength (r)')
ylabel('Number of Subjects')

% What is the least variable connection in the DMN conn matrix? How is it
% distributed over subjects?
DMN_StdMat = GrandStdMat(HIPP_F, HIPP_F);
DMN_StdMat = tril(DMN_StdMat);
DMN_StdMat(DMN_StdMat == 0) = NaN;
DMN_AllConnMat = AllConnMats(HIPP_F, HIPP_F, :);

[M,I] = min(DMN_StdMat, [], 'all', 'linear');
[X,Y] = ind2sub(size(DMN_StdMat), I);

figure;
histogram(squeeze(DMN_AllConnMat(X,Y,:)))
title(sprintf('Least Variable Connection (std = %f)', M))
subtitle(sprintf('%s --- %s', ...
    strrep(ROITbl_filt.ROIName{X}, '_', '-'), ...
    strrep(ROITbl_filt.ROIName{Y}, '_', '-')))
xlabel('Connection Strength (r)')
ylabel('Number of Subjects')
