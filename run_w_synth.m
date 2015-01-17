param.display = true;

param.velocity = 1;
param.GA_min = .1;

param.k_min = .6;
param.theta_min = cos(30 * pi/180);
param.theta_max = cos(80 * pi/180);

Qk = .0001;
Qm = .001;
Rs = .001;

param.Q = blkdiag(Qm*eye(3),Qk, Qm*eye(3),Qk);
%param.Q = blkdiag(Qm*eye(3),Qk, Qm*eye(3),Qk, Qm*eye(3),Qk);
param.R = blkdiag(Rs*eye(162));
