function setOilDrops(obj,oil_drops,v_drop)
if nargin==3
    obj.oil_drops=oil_drops;
    obj.v_drop=v_drop;
else
    img=cGLOFImageSet(obj.DirCal.alpha,obj.cal_fmt,obj.max_image);
    I_alpha=getIave(img);
    imagesc(I_alpha,[0,1]);
    n_drops = input('input number of oil drops:');
    volume_drop = input('volume of an oil drop [micro liter]:');
    volume_drop=volume_drop*10^-9; %[liter]
    dp=zeros(n_drops,4);
    for i=1:n_drops
        disp(['positon of dorp number ',int2str(i)]);
        p = ginput(2);
        % Get the x and y corner coordinates as integers
        dp(i,1) = min(floor(p(1)), floor(p(2))); %xmin
        dp(i,2) = min(floor(p(3)), floor(p(4))); %ymin
        dp(i,3) = max(ceil(p(1)), ceil(p(2)));   %xmax
        dp(i,4) = max(ceil(p(3)), ceil(p(4)));   %ymax
    end
    obj.oil_drops=dp;
    obj.v_drop=volume_drop;
end
obj.flagDrops=true;
end