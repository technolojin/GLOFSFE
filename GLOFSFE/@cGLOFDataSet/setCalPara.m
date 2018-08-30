function setCalPara(obj)
% get beta
[sp,sl]=obj.oCase.getScale(); %sl[m]
lp=sqrt((sp(1)-sp(2)).^2+(sp(3)-sp(4)).^2);
beta=lp/sl;% [pixel/m]

% get alpha
[dp,v_drop]=obj.oCase.getOilDrops();
n_drops=size(dp,1);
I_alpha=obj.CalImagesOrg.alpha;

MM=zeros(n_drops,1);
dx=1/beta;%[m/px]
dy=dx;%[m/px]
for i=1:n_drops
    MM(i) = sum(sum(I_alpha(dp(i,2):dp(i,4),dp(i,1):dp(i,3))));
end
alpha=MM*dx*dy/v_drop;    % [(calibrated)intensity/m]
alpha=median(alpha);      % median alpha

obj.CalPara.alpha=alpha;
obj.CalPara.beta=beta*obj.CalPara.scale;
obj.flagCalPara=true;
end