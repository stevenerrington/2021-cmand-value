% Define parameters for the analysis loops
monkeyList = {'darwin','Euler','joule','Xena'};
valueConds = {'lo','hi'}; % 'hi'
nSessions = length(valuedata_master.sessionN);

% For each session within our data table
for session = 1:length(valuedata_master.sessionN)
    
    % Get session information (i.e number, session name, monkey). This will
    % be useful for splitting the data in future
    postSlowingRT.sessionN(session) = valuedata_master.sessionN(session);
    postSlowingRT.session(session) = valuedata_master.session(session);
    postSlowingRT.monkey(session) = valuedata_master.monkey(session);
    
    
    % (1) Get post-slowing index for errors. (i.e. to what degree does the
    % monkey slow down after making a mistake, relative to after they get a
    % correct no-stop response). Split this by all, high, and low reward
    % context.s
    
    postSlowingRT.error_all(session) = ...
        mean(valuedata_master.postRT(session).all.noncanc) ./...
        mean(valuedata_master.postRT(session).all.nostop);
    
    postSlowingRT.error_hi(session) = ...
        mean(valuedata_master.postRT(session).hi.noncanc) ./...
        mean(valuedata_master.postRT(session).hi.nostop);
    
    postSlowingRT.error_lo(session) = ...
        mean(valuedata_master.postRT(session).lo.noncanc) ./...
        mean(valuedata_master.postRT(session).lo.nostop);
    
    % (1) Get post-slowing index for stopping. (i.e. to what degree does the
    % monkey slow down after stopping, relative to after they get a
    % correct no-stop response). Split this by all, high, and low reward
    % context.s
    
    postSlowingRT.stop_all(session) = ...
        mean(valuedata_master.postRT(session).all.canc) ./...
        mean(valuedata_master.postRT(session).all.nostop);
    
    postSlowingRT.stop_hi(session) = ...
        mean(valuedata_master.postRT(session).hi.canc) ./...
        mean(valuedata_master.postRT(session).hi.nostop);
    
    postSlowingRT.stop_lo(session) = ...
        mean(valuedata_master.postRT(session).lo.canc) ./...
        mean(valuedata_master.postRT(session).lo.nostop);
    
    
end

%%
clear x y z c m v
x = [postSlowingRT.error_lo'; postSlowingRT.error_hi'];
y = [postSlowingRT.stop_lo'; postSlowingRT.stop_hi'];
c = [repmat({'low'},length(postSlowingRT.error_lo),1);repmat({'high'},length(postSlowingRT.error_hi),1)];
m = [postSlowingRT.monkey'; postSlowingRT.monkey'];
v = [rtcomparison.both; rtcomparison.both];

for monkeyIdx = 1:4
    monkeyName = monkeyList{monkeyIdx};
    monkeyArrayIdx = []; monkeyArrayIdx = find(strcmp(m,monkeyName) == 1 ...
        & v == 1 );
    
    postSlowingFig(1,monkeyIdx)=...
        gramm('x',x(monkeyArrayIdx,:),...
        'y',y(monkeyArrayIdx,:),...
        'color',c(monkeyArrayIdx,:));
    
    postSlowingFig(1,monkeyIdx).geom_point();
    %     postSlowingFig(1,monkeyIdx).stat_cornerhist('edges',-4:0.2:4,'aspect',0.6);
    
    postSlowingFig(1,monkeyIdx).axe_property('XLim',[0.35 1.65]);
    postSlowingFig(1,monkeyIdx).axe_property('YLim',[0.35 1.65]);
    postSlowingFig(1,monkeyIdx).set_color_options('map',[colors.hi;colors.lo]);
%     postSlowingFig(1,monkeyIdx).stat_ellipse();
    postSlowingFig(1,monkeyIdx).geom_point('alpha',0.1);
    postSlowingFig(1,monkeyIdx).geom_abline(); 
    postSlowingFig(1,monkeyIdx).geom_vline('xintercept',1); postSlowingFig(1,monkeyIdx).geom_hline('yintercept',1)
end


figure('Renderer', 'painters', 'Position', [100 100 1200 250]);
postSlowingFig.draw();


%%