clear param
param.display = true;

param.GA_min = .1;

param.FA_min = .15;
param.w_min  = .4;

param.Qm = .001;
param.Ql = 10;
param.Qw = .001;
param.Rs = .02;

param.Qw = .0001;

switch 2
 case 2
  param.follow = @follow2d_2tw; param.str = '2TW';
  param.D = zeros(6,11);
  param.D(1:2,6) = [-1 1];
  [param.D(3:4,4:5) param.D(5:6,10:11)] = deal(-eye(2));
  param.d = [-.5 .9 0 0 0 0]';
  % 2TW: positive eigenvalues, .5 < w < .9
  param.lm.lb = [-inf -inf -inf 100 100 .5 -inf -inf -inf 100 100];
  param.lm.ub = [ inf  inf  inf inf inf .9  inf  inf  inf inf inf];
 case 3
  param.follow = @follow2d_3tw; param.str = '3TW';
end


