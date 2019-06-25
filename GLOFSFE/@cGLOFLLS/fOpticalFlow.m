function [ Ux,Uy ] = fOpticalFlow( I1, I2 )
% Optical Flow
% Lucas-Kanade method

Im=(I1+I2)/2;
Ix=conv2(Im,[1,1;-1,-1]/2,'valid');
Iy=conv2(Im,[1,-1;1,-1]/2,'valid');
It=conv2(-I1+I2,ones(2)/4,'valid');

C1=Ix.^2  ;
C2=Ix.*Iy;
C3=Iy.^2  ;
d1=Ix.*It;
d2=Iy.*It;

C1=conv2(C1,ones(5)/25);
C2=conv2(C2,ones(5)/25);
C3=conv2(C3,ones(5)/25);
d1=conv2(d1,ones(5)/25);
d2=conv2(d2,ones(5)/25);

Cdet=C1.*C3-C2.^2;
Ux=-(C3.*d1-C2.*d2)./Cdet;
Uy=-(C1.*d2-C2.*d1)./Cdet;

Ux=Ux(3:end-2,3:end-2);
Uy=Uy(3:end-2,3:end-2);

end