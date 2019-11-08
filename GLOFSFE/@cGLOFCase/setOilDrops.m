function setOilDrops(obj,v_drop,oil_drops)
if isempty(obj.DirCal.alpha)
   obj.flagDrops=false;
   return 
end

narginchk(1,3);

if nargin==3
    obj.v_drop=v_drop;
    obj.oil_drops=oil_drops;
elseif nargin<3
    if nargin==2
        obj.v_drop=v_drop;
    else
        volume_drop = input('please input the volume of an oil drop [micro liter]:');
        obj.v_drop = volume_drop*10^-9; %[liter]
    end
    img_alpha=cGLOFImageSet(obj.DirCal.alpha,obj.cal_fmt,obj.max_image);
    I_alpha=getIave(img_alpha);
    if ~isempty(obj.DirCal.exc)
    	img_exc=cGLOFImageSet(obj.DirCal.exc,obj.cal_fmt,obj.max_image);
    	I_exc=getIave(img_exc);
        I_alpha=I_alpha./I_exc;
        I_alpha(isinf(I_alpha))=0;
        I_alpha(isnan(I_alpha))=0;
    end
    
    
    imgq=plot.imgQuantile( I_alpha, [0.05, 0.98]);
    imagesc(I_alpha,imgq);
    colormap('winter');
    n_drops = input('please input the number of oil drops:');
    dp=zeros(n_drops,4);
    for i=1:n_drops
        disp(['positon of drop # ',int2str(i),'/',int2str(n_drops)]);
        p=zeros(2);
        hold on;
        for n=1:2
            p(n,:)=ginput(1);
            scatter(p(n,1),p(n,2),'+r','SizeData',50,'LineWidth',1.5);
        end
        hold off;
        % Get the x and y corner coordinates as integers
        dp(i,1) = min(floor(p(1)), floor(p(2))); %xmin
        dp(i,2) = min(floor(p(3)), floor(p(4))); %ymin
        dp(i,3) = max(ceil(p(1)), ceil(p(2)));   %xmax
        dp(i,4) = max(ceil(p(3)), ceil(p(4)));   %ymax
        hold on;
        plot([dp(i,1),dp(i,1),dp(i,3),dp(i,3),dp(i,1)],...
            [dp(i,2),dp(i,4),dp(i,4),dp(i,2),dp(i,2)],...
            '-r','LineWidth',0.9);
        text(dp(i,1)-10,dp(i,2),num2str(i,'%02u'),'BackgroundColor',[1,1,1],'Margin',0.1,'FontSize',8);
        hold off;
    end
    obj.oil_drops=dp;
    pause(0.1);
end
obj.flagDrops=true;
end