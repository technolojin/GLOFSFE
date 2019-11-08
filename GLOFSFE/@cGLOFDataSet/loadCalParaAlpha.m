function loadCalParaAlpha(obj,flag_showimg)

if ~isempty(obj.oCase.input_alpha) && isprop(obj.oCase,'input_alpha')
    obj.CalPara.alpha=obj.oCase.input_alpha;
    return
end

if nargin==1
    flag_showimg=false;
end

% get beta first
if isempty(obj.CalPara.beta)
    loadCalParaBeta(obj);
end
beta=obj.CalPara.beta;

%% get alpha
[dp,v_drop]=obj.oCase.getOilDrops();
n_drops=size(dp,1);
if ~obj.flagImgLoaded
   obj.LoadData();
   return
end
I_alpha=obj.CalImages.alpha;
I_alpha(isnan(I_alpha))=0;

% plot input areas 
if flag_showimg
    imgq=plot.imgQuantile( I_alpha, [0.05, 0.98]);
    imagesc(rot90(I_alpha,0),imgq);
    set(gca,'DataAspectRatio',[1,1,1]);
    for i=1:n_drops
        hold on;
        plot([dp(i,1),dp(i,1),dp(i,3),dp(i,3),dp(i,1)],...
            [dp(i,2),dp(i,4),dp(i,4),dp(i,2),dp(i,2)],...
            '-r','LineWidth',0.9);
        text(dp(i,1)-10,dp(i,2),num2str(i,'%02u'),'BackgroundColor',[1,1,1],'Margin',0.1,'FontSize',8);
        hold off;
    end
end

MM=zeros(n_drops,1);
dx=1/beta;%[m/px]
dy=dx;%[m/px]
for i=1:n_drops
    MM(i) = sum(sum(I_alpha(dp(i,2):dp(i,4),dp(i,1):dp(i,3))));
end
alpha=MM*dx*dy/v_drop;      % [(calibrated)intensity/m]
alpha=alpha(~isnan(alpha));
alpha=median(alpha);        % median alpha

obj.CalPara.alpha=alpha;
end