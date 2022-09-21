clear all
close all
masterImportplots='D:\Michael_Shannon\MartinezMaster\PIV_analysis_ICAMonly_OUTPUT_relvalpoint01magval1_9-6-2022\';


load([masterImportplots,'Alldatastatstable.mat'])

C = [0.8500, 0.3250, 0.0980;0, 0.4470, 0.7410];
myhexvalues = rgb2hex(C);
disp(myhexvalues);

uniqueconds=unique(statstable.Condition);

plotsfolder=[masterImportplots, 'Plots', '\'];
            
if ~exist (plotsfolder)
    mkdir (plotsfolder);
end

DataSheetsFolder=[masterImportplots, 'DataSheets', '\'];
            
if ~exist (DataSheetsFolder)
    mkdir (DataSheetsFolder);
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MetricOfInterest = 'SpeedMean'; %Change this for whatever metric you want

% SpeedMean ImmobileFraction MovingActinFraction kappatimewindow


uniqueconds=unique(statstable.Condition);
CondRepDataTableLarge=table();

for Cond=1:numel(uniqueconds)
    ConditionChoice=uniqueconds(Cond,:);
    CondRows=find(strcmp(ConditionChoice,statstable{:,1})); 
    SingleConditionTable=statstable(CondRows,:);
    
    UniqueReps= unique(SingleConditionTable.Replicate);
    
    for Rep=1:numel(UniqueReps)
        RepChoice=UniqueReps(Rep,:);
        RepRow=find(strcmp(RepChoice,SingleConditionTable{:,2}));
        SingleReplicateTable=SingleConditionTable(RepRow,:); % individual replicate
        SingleMetric=cell2mat(SingleReplicateTable.(MetricOfInterest)).'; % Here choose metric of interest
%         SingleMetric=SingleMetric(4:9:end-3,:); %This is only for Von Mises Limited
        SingleMetric=SingleMetric(4:end-3); %This is only for all metrics reg

        Conditionarray = cell(numel(SingleMetric), 1);
        Conditionarray(:) = {ConditionChoice};
        RepArray = cell(numel(SingleMetric), 1);
        RepArray(:) = {RepChoice};
        
        CondRepDataTable=table(Conditionarray, RepArray, SingleMetric);
        CondRepDataTableLarge=[CondRepDataTableLarge;CondRepDataTable];
    end
end
CondRepDataTableLarge=flip(CondRepDataTableLarge, 1);             
writetable(CondRepDataTableLarge,[DataSheetsFolder,MetricOfInterest,'.csv'])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Simple Violin plot for kappa total over all time points

Conditionlabels = cellstr(statstable.Condition);
data=cell2mat(statstable.kappa);
grouporder={'Condition_WT_ICAM_100x','Condition_KO_ICAM_100x'};
vs=figure();
vsp = violinplot(data, Conditionlabels,'GroupOrder',grouporder,...
    'QuartileStyle','shadow','DataStyle', 'scatter',...
    'ShowMean', true);

xlabel('Time(s)','fontsize',28);
ylabel('Flow Speed (um/min)','fontsize',28);
set(gca,'fontsize',28,'linewidth',2);
% legend(uniqueconds,...
%     'Location','northeastoutside','NumColumns',2)
grid on
vs.Position = [1024 1024 1024 1024];
Valnameimg = sprintf('TotalKappaViolin');
saveas(vs, [plotsfolder,Valnameimg], 'png');

%% OVER TIME PLOTS

errorfigure=figure();

x=[];
y=[];
t=[];
Numberofcolours=numel(uniqueconds);
t=1;
for t=1:numel(uniqueconds)
    ConditionChoice=uniqueconds(t,:);
    condrows=find(strcmp(ConditionChoice,statstable{:,1})); 
    
    firstrows=statstable(condrows,:);
    speedmean=cell2mat(firstrows.SpeedMean);
    speedmean(any(isnan(speedmean),2),:) = 0; %This removes the rows that contain nans....
    CIlower=cell2mat(firstrows.SpeedCILower);
%     CIlower(any(isnan(CIlower),2),:) = [];
    CIupper=cell2mat(firstrows.SpeedCIUpper);
%     CIupper(any(isnan(CIupper),2),:) = [];
    CIlowermean=mean(CIlower);
    CIuppermean=mean(CIupper);
    err=[CIuppermean;CIlowermean];
    err=err(:,3:end-2);
    y = speedmean(:,4:end-3); %removes first two and last two elements because they are mad. 
    x=1:size(y,2);
%     x=[x;x;x;x]
%     C = linspecer(Numberofcolours);% This makes a cycling colour map. Note - these are OK but you could use better ones.
    overallmeans=mean(y);

    errorfig=shadedErrorBar(x,y,{@mean,@std},'lineProps',{'-o','markerfacecolor',[C(t,:)],'color',[C(t,:)]},'transparent',1,'patchSaturation',0.33);
%     errorfig=shadedErrorBar(x,y,{@mean,@std},'lineProps',{'-o'},'transparent',1,'patchSaturation',0.33);
%     errorfig=shadedErrorBar(x,overallmeans,err,'lineProps',{'-o','markerfacecolor',[C(t,:)],'color',[C(t,:)]},'transparent',1,'patchSaturation',0.33);
%     plot(x,overallmeans);
    ylim([0 5])

    hold on
end

xlabel('Time(s)','fontsize',28);
ylabel('Flow Speed (um/min)','fontsize',28);
set(gca,'fontsize',28,'linewidth',2);
% legend(uniqueconds,...
%     'Location','northeastoutside','NumColumns',2)
grid on
errorfigure.Position = [1024 512 1024 512];
Valnameimg = sprintf('ActinFlowTime');
saveas(errorfigure, [plotsfolder,Valnameimg], 'png');

%%%%%%%%%%

%%

% OVER TIME IMMOBILE

errorfig2=figure();
uniqueconds=unique(statstable.Condition);
x=[];
y=[];
t=[];
immobile=[];
Numberofcolours=numel(uniqueconds);
t=1;
for t=1:numel(uniqueconds)
    ConditionChoice=uniqueconds(t,:);
    condrows=find(strcmp(ConditionChoice,statstable{:,1})); 
    
    firstrows=statstable(condrows,:);
    immobile=cell2mat(firstrows.ImmobileFraction);
    immobilepercentage=immobile*100;

    y = immobilepercentage(:,4:end-3); %removes first two and last two elements because they are mad. 
    x=1:size(y,2);
%     x=[x;x;x;x]
%     C = linspecer(Numberofcolours);% This makes a cycling colour map. Note - these are OK but you could use better ones.


    errorfig=shadedErrorBar(x,y,{@mean,@std},'lineProps',{'-o','markerfacecolor',[C(t,:)],'color',[C(t,:)]},'transparent',1,'patchSaturation',0.33);
%     errorfig=shadedErrorBar(x,overallmeans,err,'lineProps',{'-o','markerfacecolor',[C(t,:)],'color',[C(t,:)]},'transparent',1,'patchSaturation',0.33);
%     plot(x,overallmeans);
    ylim([0 100])
    hold on
end

xlabel('Time(s)','fontsize',28);
ylabel('Percent Immobile','fontsize',28);
set(gca,'fontsize',28,'linewidth',2);
% legend(uniqueconds,...
%     'Location','northeastoutside','NumColumns',2)
grid on
errorfig2.Position = [1024 512 1024 512];
Valnameimg = sprintf('ImmobilePercentTime');
saveas(errorfig2, [plotsfolder,Valnameimg], 'png');

%%

% Von MISES OVER TIME

errorfig3=figure();
uniqueconds=unique(statstable.Condition);
x=[];
y=[];
t=[];
kappa=[];
Numberofcolours=numel(uniqueconds);
% t=1;
for t=1:numel(uniqueconds)
    ConditionChoice=uniqueconds(t,:);
    condrows=find(strcmp(ConditionChoice,statstable{:,1})); 
    firstrows=statstable(condrows,:);
    kappa=cell2mat(firstrows.kappatimewindow);
    y = kappa(:,4:end-3); %removes first two and last two elements because they are mad. 
    x=1:size(y,2);
%     x=[x;x;x;x]
%     C = linspecer(Numberofcolours);% This makes a cycling colour map. Note - these are OK but you could use better ones.
    errorfig=shadedErrorBar(x,y,{@median,@std},'lineProps',{'-o','markerfacecolor',[C(t,:)],'color',[C(t,:)]},'transparent',1,'patchSaturation',0.33);
%     errorfig=shadedErrorBar(x,overallmeans,err,'lineProps',{'-o','markerfacecolor',[C(t,:)],'color',[C(t,:)]},'transparent',1,'patchSaturation',0.33);
%     plot(x,overallmeans);
    ylim([-0.5 3])
    hold on
end

xlabel('Time(s)','fontsize',28);
ylabel('Concentration Of Motion κ','fontsize',28);
set(gca,'fontsize',28,'linewidth',2);
% legend(uniqueconds,...
%     'Location','northeastoutside','NumColumns',2)
grid on
errorfig3.Position = [1024 512 1024 512];
Valnameimg = sprintf('VonMisesTime');
saveas(errorfig3, [plotsfolder,Valnameimg], 'png');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% VON MISES OVER TIME, but CUT TO no overlapping frames.

errorfig3=figure();
uniqueconds=unique(statstable.Condition);
x=[];
y=[];
t=[];
kappa=[];
Numberofcolours=numel(uniqueconds);
% t=1;
for t=1:numel(uniqueconds)
    ConditionChoice=uniqueconds(t,:);
    condrows=find(strcmp(ConditionChoice,statstable{:,1})); 
    firstrows=statstable(condrows,:);
    
    kappa=cell2mat(firstrows.kappatimewindow);
    kappalimited=kappa(:, 1:9:end); %rows are replicates, columns are timepoints. This is cut by the overlap (9), so that it no longer overlaps.
    y = kappalimited; %removes first two and last two elements because they are mad. 
    
    x=1:size(y,2);
%     x=[x;x;x;x]
%     C = linspecer(Numberofcolours);% This makes a cycling colour map. Note - these are OK but you could use better ones.
    errorfig=shadedErrorBar(x,y,{@median,@std},'lineProps',{'-o','markerfacecolor',[C(t,:)],'color',[C(t,:)]},'transparent',1,'patchSaturation',0.33);
%     errorfig=shadedErrorBar(x,overallmeans,err,'lineProps',{'-o','markerfacecolor',[C(t,:)],'color',[C(t,:)]},'transparent',1,'patchSaturation',0.33);
%     plot(x,overallmeans);
    hold on
end

xlabel('Time window number','fontsize',28);
ylabel('Von Mises Directional Persistence','fontsize',28);
set(gca,'fontsize',28,'linewidth',2);
legend(uniqueconds,...
    'Location','northeastoutside','NumColumns',2)
grid on
