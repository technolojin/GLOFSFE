function [UnitH,UnitLength,UnitTime,UnitTau]=getUnit(obj)
if ~obj.flagCalPara
    UnitH=1;
    UnitLength=1;
    UnitTime=1;
    UnitTau=1;
    fprintf(1,'@cGLOFDataSet.getUnit: Not fully calibrated. Return default unit values.\n');
    return
end

CalPara=obj.CalPara;
alpha=CalPara.alpha;
beta=CalPara.beta;
gamma=CalPara.gamma;
visc_oil=CalPara.visc_oil;
scale=CalPara.scale;

Texp=CalPara.Texp;
exp_adj=Texp.run/Texp.alpha;

UnitH=1/(alpha*exp_adj);
UnitLength=1/(beta*scale);
UnitTime=1/gamma;
UnitTau=(visc_oil*UnitLength)/(UnitH*UnitTime);

end
