function [ tau_x,tau_y ] = fTauVec2Field( tau,ni,nj )
% reshape
tau=reshape(tau,[ni nj 2]);
tau_x=tau(:,:,1);
tau_y=tau(:,:,2);

% remove extreme value
tau_mag=sqrt(tau_x.^2+tau_y.^2);
tau_x_med=medfilt2(tau_x,[5, 5]);
tau_y_med=medfilt2(tau_y,[5, 5]);
tau_x(tau_mag>50)=tau_x_med(tau_mag>50);
tau_y(tau_mag>50)=tau_y_med(tau_mag>50);

% vectors to node-center
f_v2n=[0,1;0,1]/2;
tau_x=conv2(tau_x,f_v2n ,'valid');
tau_y=conv2(tau_y,f_v2n','valid');

end

