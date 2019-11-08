function loadCalParaBeta(obj)
if ~isempty(obj.oCase.input_beta) && isprop(obj.oCase,'input_beta')
    obj.CalPara.beta=obj.oCase.input_beta;
    return
end
% get beta
[sp,sl]=obj.oCase.getScale(); %sl[m]
lp=sqrt((sp(1)-sp(2)).^2+(sp(3)-sp(4)).^2);
beta=lp/sl;% [pixel/m]

obj.CalPara.beta=beta;

end