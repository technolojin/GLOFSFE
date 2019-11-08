function setScale(obj,scale_points,scale_length)
if isempty(obj.DirCal.scale)
   obj.flagScale=false;
   return 
end

if nargin==3
    obj.scale_points=scale_points;
    obj.scale_length=scale_length;
else
    img=cGLOFImageSet(obj.DirCal.scale,obj.cal_fmt,obj.max_image);
    I_scale=getIave(img);
    imgq=plot.imgQuantile( I_scale, [0.05, 0.98]);
    imagesc(I_scale,imgq);
    colormap('winter');
    disp('click two points to measure');
    p=zeros(2);
    hold on;
    for n=1:2
        p(n,:)=ginput(1);
        scatter(p(n,1),p(n,2),'xr','SizeData',100);
    end
    hold off;
    hold on;
    plot([p(1),p(2)],[p(3),p(4)],'-r','LineWidth',0.9);
    hold off;
    for i=1:10
        length = input('please input the length read [mm]:');
        if isnumeric(length)
            length=length/1000;
            break
        elseif i==10
            error('wrong input');
        else
            disp('wrong input. try again');
        end
    end
    obj.scale_points=p;
    obj.scale_length=length;
end
obj.flagScale=true;
end