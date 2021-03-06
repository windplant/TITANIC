% function DisplayChannelStatus(tower,datastream,qcd,FStatus)
%
% show instrument availability

function SubDisplayChannelStatus(tower,datastream,qcd,FStatus)

%% CREATE AXES
axlights = axes('position',[0.05 0.05 0.65 0.85],'Parent',FStatus);
axfile = axes('position',[0.775 0.55 0.15 0.35],'Parent',FStatus);

%% GET NOMINAL HEIGHT
DO_VALUES = 0;

% first figure out which row each data point goes into
for di = 1:numel(qcd.datastream)
    if (di<=numel(datastream))
        if ~isempty(datastream{di})
            % check to see if we want this data
        if datastream{di}.qc.doqc
            z_nominal(di) = 3*floor(datastream{di}.config.height/3);
        else
            z_nominal(di) = NaN;
        end
        end
	end    
end

% figure out which column
zs = unique(z_nominal);
for zi = 1:numel(zs)
    % get the instruments in this row
    zii = find(z_nominal==zs(zi));
    col_nominal(zii) = 1:numel(zii);
end
%% PLOT DATA QUALITY
bad_timing = 0;
for di = 1:numel(qcd.datastream)
    if (di<=numel(datastream))
        if ~isempty(datastream{di})
            % check to see if we want this data
            
            if datastream{di}.qc.doqc
                % did this datastream generate a flag or not?
                flagged = sum(qcd.datastream{di}.flags < 5000) >= 1;
                failed = sum(qcd.datastream{di}.flags > 5000) >= 1;
                
                % check what color we will make the indicator
                clr = [0 0 0];
                if flagged == 1
                    clr = [0.8 0.8 0.8];
                end
                if failed == 1
                    clr = [1 0.1 0.1];
                end
                
                % and plot the warning somewhere in space
                dy = z_nominal(di);
                dx = 30*(col_nominal(di)-1);
                
                plot(axlights,dx,dy,...
					'ks',...
					'MarkerFaceColor',clr)
				hold(axlights,'on')
                
                % add some information
                titlestr = [ num2str(di) ': '...
                    strrep(datastream{di}.instrument.variable,'_',' ')];
           
                % print this information
                text('String',...
                    {[titlestr ]},...%'.' inrangestr]},...
                    'Position',[dx+2 dy],...
                    'HorizontalAlignment','left',...
                    'FontSize',8,'Tag','info',...
                    'BackgroundColor','w',...
                    'Parent',axlights)
            end
        end
    end
end

%% rest x limits
xlim(axlights,[-2 max(xlim(axlights))])

%% axes and labels
title(axlights,...
    [datestr(qcd.file.starttime) ' ' tower.timezone ': Channel Status'])
%set(axlights,'DataAspectRatio',[1 1 1])
ylabel(axlights,'Nominal Height [m]')
zdiff = max(z_nominal) - min(z_nominal);
ylim(axlights,[min(z_nominal)- 0.05*zdiff max(z_nominal)+ 0.05*zdiff])
pretty_xyplot(axlights)
set(axlights,'XTick',[])
set(axlights,'XTickLabel','')

%% FILE INFORMATION
% use axfile
xlim(axfile,[0 1])
ylim(axfile,[0 1])
text(0, 0.5,...
    {[datestr(qcd.file.starttime,'dd mmmm yyyy HH:MM') ...
    ' ' tower.timezone ];...
    ' ';....
    ['Data file: ' strrep(tower.processing.datafile.name,'_','\_')];...
    ['Processed on: ' datestr(datenum(tower.processing.datevec), 'dd mmmm yyyy, HH:MM')];...
    ['Configuration file: ' strrep(tower.processing.configfile.name,'_','\_')];...
    ['Code version: ' num2str(tower.processing.code.version,'%3.3f')...
    ' (' datestr(tower.processing.code.date,'mmm dd yyyy') ')'];...
    ['Host: ' tower.processing.hostname];...
    '';...
    'LEGEND:';...
    'Text: Channel: Name height, % OK';...
    'Markers: Black: OK. Gray: flagged. Red: failed.'},...
    'HorizontalAlignment','left',...
    'VerticalAlignment','middle',...
    'Parent',axfile)
set(axfile,'Visible','off')
%title(axfile,'File Information')