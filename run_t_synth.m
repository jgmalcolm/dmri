clear param
param.display = true;

% param.GA_min = 0;  % for 3T, b=1000
% param.FA_min = 0;
param.GA_min = .1;
param.FA_min = .15;

param.Qm = .001;
param.Ql = 10;
param.Rs = .02;

param.str = '1T';

switch param.str;
 case '1T'
  param.follow = @follow2d_1t;
 case '2T'
  param.follow = @follow2d_2t;
 case '3T'
  param.GA_min = 0;
  param.follow = @follow2d_3t;
 case 'LM'
  param.follow = @follow2d_lm;
  param.lm.lb = repmat([-inf -inf -inf 100 100], [1 2]);
  param.lm.ub = []; % none
end
