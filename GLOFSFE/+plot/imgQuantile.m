function [ imgq ] = imgQuantile( img, Q)
% 'Q' quantile of the given image
temp=sort(nonzeros(img(:)));
nt=size(temp,1)-1;
imgq=temp(floor(nt.*Q)+1)';
end

