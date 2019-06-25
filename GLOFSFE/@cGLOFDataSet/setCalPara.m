function setCalPara(obj,gamma,visc_oil,Texp_ratio)

narginchk(3,4);
if nargin==3
    Texp_ratio=[1,1,1];
end

obj.CalPara.gamma=gamma;
obj.CalPara.visc_oil=visc_oil;
obj.CalPara.Texp_ratio=Texp_ratio;

if obj.oCase.flagScale==false
    obj.oCase.setScale();
end
if obj.oCase.flagDrops==false
    obj.oCase.setOilDrops();
end

obj.flagCalPara=true;


end