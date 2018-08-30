function setScale(obj,scale_points,scale_length)
if nargin==3
    obj.scale_points=scale_points;
    obj.scale_length=scale_length;
else
    img=cGLOFImageSet(obj.DirCal.scale,obj.cal_fmt,obj.max_image);
    I_scale=getIave(img);
    imagesc(I_scale,[0,1]);
    disp('click two points to measure');
    points = ginput(2);
    for i=1:10
        length = input('input length read in [mm]:');
        length=length/1000;
        if isnumeric(length)
            break
        elseif i==10
            error('wrong input');
        else
            disp('wrong input. try again');
        end
    end
    obj.scale_points=points;
    obj.scale_length=length;
end
obj.flagScale=true;
end