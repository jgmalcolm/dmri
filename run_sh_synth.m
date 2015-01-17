param.display = true;

param.velocity = 2;
param.GA_min = .1;

param.theta_min = cos(30 * pi/180);
param.theta_max = cos(80 * pi/180);

Qc = 1e-7;
%Rs = .002;
Rs = .02;

param.Q = blkdiag(Qc*eye((sh.L+1)*(sh.L+2)/2));
param.R = blkdiag(Rs*eye(162));

return
fibers_kf=follow2d_2w(T.S, u, b, param);
