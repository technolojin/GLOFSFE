function [ Xp, Yp] = RescaleRotCoor( X,Y,scale,angle,p0)
xc=p0(1);
yc=p0(2);
theta=angle/180*pi(); %convert degree to radian
A=scale.*[cos(theta),-sin(theta);sin(theta),cos(theta)]; %rotation matrix with scale factor
B=eye(2)-A;
Xp=A(1,1).*X+A(1,2).*Y+B(1,1).*xc+B(1,2).*yc;
Yp=A(2,1).*X+A(2,2).*Y+B(2,1).*xc+B(2,2).*yc;

end

