function setCalPara(obj,gamma,visc_oil,Texp_ratio)

narginchk(3,4);
if nargin==3
    Texp_ratio=[1,1,1];
end

obj.CalPara.gamma=gamma;
obj.CalPara.visc_oil=visc_oil;
obj.CalPara.Texp_ratio=Texp_ratio;

if obj.oCase.flagScale==false
    obj.oCase.setScale(); % input scale points if calibration directory is set
end
if obj.oCase.flagDrops==false
    obj.oCase.setOilDrops(); % input droplet points if calibration directory is set
end

if obj.oCase.flagScale && obj.oCase.flagDrops
    obj.flagCalPara=true;
end

end