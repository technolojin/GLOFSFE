function plot_tau(tau_x, tau_y, img, fignumb)
%PLOT_TAU plot skin friction field
%
%*1 Vector field (quiver) 
%    Vector length is normalized, insted, arrows are colored by its 
%   magnitude. Vector density can be controlled by 'gx', which means the 
%   number of arrows on short axis.
%
%*2 Streamline with the given GLOF image
%
%*3 Magnitude distribution
%
%
%See also:
% quiver_mod
% 
% 
% Copyright (c) 2018 Taekjin Lee
% Released under the MIT license
% http://opensource.org/licenses/mit-license.php

if nargin<4
    fignumb=1;
end

if size(tau_x,3)>1
    tau_x=tau_x(:,:,1);
    tau_y=tau_y(:,:,1);
end

tau_x(isnan(tau_x))=0;
tau_y(isnan(tau_y))=0;

%% tau vector field
figure(fignumb);
axis xy;
gx=35; offset=1;
plot.quiver_mod (tau_x', tau_y','vectorNumber',gx,'Offset',offset,'LineWidth',0.8);
set(gca,'DataAspectRatio',[1,1,1]);	
xlabel('x (pixels)');
ylabel('y (pixels)');
title('Skin Friction Vector Field');

%% tau streamlines
figure(fignumb+1);
colormap bone;
axis xy;
hold on;
imagesc(img',[0 1.5]);
axis image;
stream_slice=streamslice(tau_x', tau_y', 5);
set(stream_slice, 'Color', 'white','LineWidth',0.8);
hold off;
xlabel('x (pixels)');
ylabel('y (pixels)');
title('Skin Friction Lines');

%% tau magnitude field
tau_mag=(tau_x.^2+tau_y.^2).^0.5;

% Quantile of 95% in the image
imgq=plot.imgQuantile(tau_mag, [0,0.95]);

figure(fignumb+2);
colormap jet;
axis xy;
hold on;
imagesc(tau_mag',imgq);
axis image;
hold off;
xlabel('x (pixels)');
ylabel('y (pixels)');
title('Skin Friction Magnitude Field');
colorbar;

end

