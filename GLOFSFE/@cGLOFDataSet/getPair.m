function [I1,I2]=getPair(obj,np,use_gpu)

if nargin==2
    use_gpu=false;
end

I1=getImage(obj,obj.PairList(np,1),obj.PairList(np,2),use_gpu);
I2=getImage(obj,obj.PairList(np,1),obj.PairList(np,3),use_gpu);

end

