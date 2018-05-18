function MultiPlotFDACurves(FDAcellfile,colormapfile,ylimdatarange,ylimrange,ylimvelrange,ylimaccrange,outsuffix,subrange,varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
plottype=1;
imagesuffix='.tif';
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if ischar(varargin{i})
            switch(varargin{i})
                case('scatterplusmean')
                    plottype=2;
                case('meanonly')
                    plottype=3;
                case('imagesuffix')
					imagesuffix=varargin{i+1};
            end
        end
    end
end
load(FDAcellfile,'commcellmat','timepts','timecellmat','datacellmat','accmat','velmat');
if exist('subrange','var') == 0
    subrange = 1;
end
if exist('colormapdata','var')
    colormapdata = struct2array(load(colormapfile));
else
    colormapdata = [1,0,0,1,0.700000000000000,0.700000000000000;0,0,1,0.700000000000000,0.700000000000000,1;1,0.700000000000000,0,1,0.700000000000000,0.500000000000000;1,0,1,1,0.700000000000000,1;0.500000000000000,0.500000000000000,0,0.500000000000000,0.500000000000000,0.200000000000000];
end
[ncommunities,ntrajectories] = size(commcellmat);
count = 0;
if size(colormapdata,1) < ncommunities
    colormapdata(end+1:ncommunities,:) = repmat(zeros(1,6),ncommunities-size(colormapdata,1),1);
end
for current_trajectory = 1:ntrajectories
    commcellmat_temp = commcellmat(:,current_trajectory);
    timepts_temp = timepts{current_trajectory};
    datacellmat_temp = datacellmat(:,current_trajectory);
    timecellmat_temp = timecellmat(:,current_trajectory);
    if exist('ylimdatarange','var')
        for j = 1:length(commcellmat_temp)
            commcount = 0;
            for i = 1:size(commcellmat_temp{j},1)
                if max(commcellmat_temp{j}(i,:)) < ylimdatarange(2)
                    if min(commcellmat_temp{j}(i,:)) > ylimdatarange(1)
                        if size(commcellmat_temp{j},1) > subrange
                            commcount = commcount + 1;
                            commcellmat_tempnew{j}(commcount,:) = commcellmat_temp{j}(i,:);
                            datacellmat_tempnew{j}(commcount,:) = datacellmat_temp{j}(i,:);
                            timecellmat_tempnew{j}(commcount,:) = timecellmat_temp{j}(i,:);
                        end
                    end
                end
            end
        end
        commcellmat_temp = commcellmat_tempnew;
        datacellmat_temp = datacellmat_tempnew;
        timecellmat_temp = timecellmat_tempnew;
    end
    h = figure(1);
    count = count + 1;
    subplot(ntrajectories,size(commcellmat_temp,2)+1,count);
    if size(commcellmat_temp{1},1) > 1
        for cols = 1:size(commcellmat_temp{1},2)
            mean_commcellmat_temp(cols) = mean(commcellmat_temp{1}((isnan(commcellmat_temp{1}(:,cols)) == 0),cols));
        end
        plot(timepts_temp,mean_commcellmat_temp,'Color',colormapdata(1,1:3),'LineWidth',3)
        clear mean_commcellmat_temp
    else
        plot(timepts_temp,commcellmat_temp{1},'Color',colormapdata(1,1:3),'LineWidth',3)
    end
    hold
    for j = 2:length(commcellmat_temp)
        if size(commcellmat_temp{j},1) > 1
            for cols = 1:size(commcellmat_temp{j},2)
                mean_commcellmat_temp(cols) = mean(commcellmat_temp{j}((isnan(commcellmat_temp{j}(:,cols)) == 0),cols));
            end
            plot(timepts_temp,mean_commcellmat_temp,'Color',colormapdata(j,1:3),'LineWidth',3)
            clear mean_commcellmat_temp
        elseif isempty(commcellmat_temp{j})
        else
            plot(timepts_temp,commcellmat_temp{j}.','Color',colormapdata(j,1:3),'LineWidth',3)
        end
    end
    if exist('ylimrange','var')
        ylim([ylimrange(1) ylimrange(2)])
    end
    title('All','FontSize',10,'FontWeight','Bold','FontName','Arial')
    xlabel('time','FontSize',8,'FontWeight','Bold','FontName','Arial')
    ylabel('metric','FontSize',8,'FontWeight','Bold','FontName','Arial')
    for j = 1:length(commcellmat_temp)
        count = count + 1;
        subplot(ntrajectories,size(commcellmat_temp,2)+1,count);
    if isempty(commcellmat_temp{j}) == 0    
        for cols = 1:size(commcellmat_temp{j},2)
            mean_commcellmat_temp(cols) = mean(commcellmat_temp{j}((isnan(commcellmat_temp{j}(:,cols)) == 0),cols));
        end
        plot(timepts_temp,mean_commcellmat_temp,'Color',colormapdata(j,1:3),'LineWidth',3)
        clear mean_commcellmat_temp
        title(strcat('group #',num2str(j)),'FontSize',10,'FontWeight','Bold','FontName','Arial')
        xlabel('time','FontSize',8,'FontWeight','Bold','FontName','Arial')
        ylabel('metric','FontSize',8,'FontWeight','Bold','FontName','Arial')
        hold
        if plottype < 3
            for i = 1:size(datacellmat_temp{j},1)
                scatter(timecellmat_temp{j}(i,:),datacellmat_temp{j}(i,:),'MarkerEdgeColor',colormapdata(j,4:6))
            end
            if plottype < 2
                for i = 1:size(commcellmat_temp{j},1)
                    plot(timepts_temp,commcellmat_temp{j}(i,:),'Color',colormapdata(j,4:6))
                end
            end
        end
        for cols = 1:size(commcellmat_temp{j},2)
            mean_commcellmat_temp(cols) = mean(commcellmat_temp{j}((isnan(commcellmat_temp{j}(:,cols)) == 0),cols));
        end
        plot(timepts_temp,mean_commcellmat_temp,'Color',colormapdata(j,1:3),'LineWidth',3)
        clear mean_commcellmat_temp
        if exist('ylimrange','var')
            ylim([ylimrange(1) ylimrange(2)])
        end
    end
    end
end
set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
if exist('outsuffix','var')
    saveas(h,strcat(outsuffix,'_data',imagesuffix));
end
close all
count = 0;
for current_trajectory = 1:ntrajectories
    timepts_temp = timepts{current_trajectory};
    velmat_temp = velmat(:,current_trajectory);
    commcellmat_temp = commcellmat(:,current_trajectory);
    if exist('ylimdatarange','var')
        for j = 1:length(commcellmat_temp)
            commcount = 0;
            for i = 1:size(commcellmat_temp{j},1)
                if max(commcellmat_temp{j}(i,:)) < ylimdatarange(2)
                    if min(commcellmat_temp{j}(i,:)) > ylimdatarange(1)
                        if size(velmat_temp{j},1) > subrange
                            commcount = commcount + 1;
                            velmat_tempnew{j}(commcount,:) = velmat_temp{j}(i,:);
                        end
                    end
                end
            end
        end
        velmat_temp = velmat_tempnew;
    end    
    h = figure(1);
    count = count + 1;
    subplot(ntrajectories,size(velmat_temp,2)+1,count);
    if size(velmat_temp{1},1) > 1
        for cols = 1:size(velmat_temp{1},2)
            mean_velmat_temp(cols) = mean(velmat_temp{1}((isnan(velmat_temp{1}(:,cols)) == 0),cols));
        end
        plot(timepts_temp,mean_velmat_temp,'Color',colormapdata(1,1:3),'LineWidth',3)
        clear mean_velmat_temp
    else
        plot(timepts_temp,velmat_temp{1},'Color',colormapdata(1,1:3),'LineWidth',3)
    end
    hold
    for j = 2:length(velmat_temp)
        if size(velmat_temp{j},1) > 1
            for cols = 1:size(velmat_temp{j},2)
                mean_velmat_temp(cols) = mean(velmat_temp{j}((isnan(velmat_temp{j}(:,cols)) == 0),cols));
            end
            plot(timepts_temp,mean_velmat_temp,'Color',colormapdata(j,1:3),'LineWidth',3)
            clear mean_velmat_temp
        elseif isempty(velmat_temp{j})
        else
            plot(timepts_temp,velmat_temp{j},'Color',colormapdata(j,1:3),'LineWidth',3)
        end
    end
    title('All','FontSize',10,'FontWeight','Bold','FontName','Arial')
    xlabel('time','FontSize',8,'FontWeight','Bold','FontName','Arial')
    ylabel('metric','FontSize',8,'FontWeight','Bold','FontName','Arial')
    if exist('ylimvelrange','var')
        ylim([ylimvelrange(1) ylimvelrange(2)])
    end    
    for j = 1:length(velmat_temp)
        count = count + 1;
        subplot(ntrajectories,size(velmat_temp,2)+1,count);
        if isempty(velmat_temp{j}) == 0
        for cols = 1:size(velmat_temp{j},2)
            mean_velmat_temp(cols) = mean(velmat_temp{j}((isnan(velmat_temp{j}(:,cols)) == 0),cols));
        end
        plot(timepts_temp,mean_velmat_temp,'Color',colormapdata(j,1:3),'LineWidth',3)
        clear mean_velmat_temp
        title(strcat('group #',num2str(j)),'FontSize',10,'FontWeight','Bold','FontName','Arial')
        xlabel('time','FontSize',8,'FontWeight','Bold','FontName','Arial')
        ylabel('metric','FontSize',8,'FontWeight','Bold','FontName','Arial')
        hold
        for i = 1:size(velmat_temp{j},1)
            plot(timepts_temp,velmat_temp{j}(i,:),'Color',colormapdata(j,4:6))
        end
        for cols = 1:size(velmat_temp{j},2)
            mean_velmat_temp(cols) = mean(velmat_temp{j}((isnan(velmat_temp{j}(:,cols)) == 0),cols));
        end
        plot(timepts_temp,mean_velmat_temp,'Color',colormapdata(j,1:3),'LineWidth',3)
        clear mean_velmat_temp
        if exist('ylimvelrange','var')
            ylim([ylimvelrange(1) ylimvelrange(2)])
        end
        end
    end
end
set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
if exist('outsuffix','var')
    saveas(h,strcat(outsuffix,'_velocity',imagesuffix));
end
close all
count = 0;
for current_trajectory = 1:ntrajectories
    timepts_temp = timepts{current_trajectory};
    accmat_temp = accmat(:,current_trajectory);
    commcellmat_temp = commcellmat(:,current_trajectory);
    if exist('ylimdatarange','var')
        for j = 1:length(commcellmat_temp)
            commcount = 0;
            for i = 1:size(commcellmat_temp{j},1)
                if max(commcellmat_temp{j}(i,:)) < ylimdatarange(2)
                    if min(commcellmat_temp{j}(i,:)) > ylimdatarange(1)
                        if size(accmat_temp{j},1) > subrange
                            commcount = commcount + 1;
                            accmat_tempnew{j}(commcount,:) = accmat_temp{j}(i,:);
                        end
                    end
                end
            end
        end
        accmat_temp = accmat_tempnew;
    end    
    h = figure(1);
    count = count + 1;
    subplot(ntrajectories,size(accmat_temp,2)+1,count);
    if size(accmat_temp{1},1) > 1
        for cols = 1:size(accmat_temp{j},2)
            mean_accmat_temp(cols) = mean(accmat_temp{j}((isnan(accmat_temp{j}(:,cols)) == 0),cols));
        end
        plot(timepts_temp,mean_accmat_temp,'Color',colormapdata(1,1:3),'LineWidth',3)
        clear mean_accmat_temp
    else
        plot(timepts_temp,accmat_temp{1},'Color',colormapdata(1,1:3),'LineWidth',3)
    end
    hold
    for j = 2:length(accmat_temp)
        if size(accmat_temp{j},1) > 1
        for cols = 1:size(accmat_temp{j},2)
            mean_accmat_temp(cols) = mean(accmat_temp{j}((isnan(accmat_temp{j}(:,cols)) == 0),cols));
        end
        plot(timepts_temp,mean_accmat_temp,'Color',colormapdata(j,1:3),'LineWidth',3)
        clear mean_accmat_temp
        elseif isempty(accmat_temp{j})
        else
            plot(timepts_temp,accmat_temp{j},'Color',colormapdata(j,1:3),'LineWidth',3)
        end
    end
    title('All','FontSize',10,'FontWeight','Bold','FontName','Arial')
    xlabel('time','FontSize',8,'FontWeight','Bold','FontName','Arial')
    ylabel('metric','FontSize',8,'FontWeight','Bold','FontName','Arial')
    if exist('ylimaccrange','var')
        ylim([ylimaccrange(1) ylimaccrange(2)])
    end        
    for j = 1:length(accmat_temp)
        count = count + 1;
        subplot(ntrajectories,size(accmat_temp,2)+1,count);
        if isempty(accmat_temp{j}) == 0
        for cols = 1:size(accmat_temp{j},2)
            mean_accmat_temp(cols) = mean(accmat_temp{j}((isnan(accmat_temp{j}(:,cols)) == 0),cols));
        end
        plot(timepts_temp,mean_accmat_temp,'Color',colormapdata(j,1:3),'LineWidth',3)
        clear mean_accmat_temp
        title(strcat('group #',num2str(j)),'FontSize',10,'FontWeight','Bold','FontName','Arial')
        xlabel('time','FontSize',8,'FontWeight','Bold','FontName','Arial')
        ylabel('metric','FontSize',8,'FontWeight','Bold','FontName','Arial')
        hold
        for i = 1:size(accmat_temp{j},1)
            plot(timepts_temp,accmat_temp{j}(i,:),'Color',colormapdata(j,4:6))
        end
        for cols = 1:size(accmat_temp{j},2)
            mean_accmat_temp(cols) = mean(accmat_temp{j}((isnan(accmat_temp{j}(:,cols)) == 0),cols));
        end
        plot(timepts_temp,mean_accmat_temp,'Color',colormapdata(j,1:3),'LineWidth',3)
        clear mean_accmat_temp
        if exist('ylimaccrange','var')
            ylim([ylimaccrange(1) ylimaccrange(2)])
        end 
        end
    end     
end
set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
if exist('outsuffix','var')
    saveas(h,strcat(outsuffix,'_acceleration',imagesuffix));
end
end

