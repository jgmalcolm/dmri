function ff_ = run(model, varargin)
% RUN(MODEL) Begins a run on case01045
% RUN(MODEL,'div', 1, 'ndiv', 4) Part one of four.
% RUN(MODEL, 'is_temp', true)  Temporary run.
  paths;
  
  dir = '/Users/malcolm/src/dmri';
  param.backup = .5; % every xx% of progress
  
  try
    [S mask u b] = evalin('caller', 'deal(S,mask,u,b)');
  catch
    [S mask u b] = loadsome('matlab', 'S', 'mask', 'u', 'b');
  end

  param.FA_min = .15;
  param.GA_min = .1;
  param.seeds = 10;
  param.seed_GA = .18;
  param.voxel = [1.66 1.66 1.70];

  param.max_len = 250;
  param.min_radius = 0.87;

  param.is_temp = false;
  param.ndiv = 1;
  param.div  = 1;
  
  switch model
   case 'DT',  follow = @follow3d_dt;   init = @init_fibers_dt;
    param.dt = .3;

   case '1T',  follow = @follow3d_1t;   init = @init_fibers_1t;
    param.Qm = .0015;
    param.Ql = 25;
    param.Rs = .020;
    param.dt = .3;
    param.P0 = eye(5)/100;%double(loadsome('/home/yogesh/yogesh_pi/phd/dwmri/ukf_tensor/avg_cov','P'));
    
    save initial_params param
    return

   case '2T',  follow = @follow3d_2t;   init = @init_fibers_2t;
    param.Qm = .0030;
    param.Ql = 100;
    param.Rs = .015;
    param.dt = .2;
    param.P0 = eye(10)/100;%double(loadsome('/home/yogesh/yogesh_pi/phd/dwmri/ukf_tensor/avg_cov_2T','X'));

   case '3T',  follow = @follow3d_3t;   init = @init_fibers_3t;
    param.Qm = .0045;
    param.Ql = 100;
    param.Rs = .015;
    param.dt = .2;

   case '2TW', follow = @follow3d_2tw;  init = @init_fibers_2tw;
    param.Qw = .001;
    param.D = zeros(6,11);
    param.D(1:2,6) = [-1 1];
    [param.D(3:4,4:5) param.D(5:6,10:11)] = deal(-eye(2));
    param.d = [-.5 .9 0 0 0 0]';

   case 'LM', follow = @follow3d_2t_lm; init = @init_fibers_2t;
    param.P0 = nan;
    param.dt = .2;
    param.lm.lb = [-inf -inf -inf 100 100 -inf -inf -inf 100 100];
    param.lm.ub = [ inf  inf  inf inf inf  inf  inf  inf inf inf];

   case 'LMi', follow = @follow_lm_i; init = @init_fibers_2t;
    param.P0 = nan;
    param.dt = .3;
    param.lm.lb = [-inf -inf -inf 100 100 -inf -inf -inf 100 100];
    param.lm.ub = [ inf  inf  inf inf inf  inf  inf  inf inf inf];
    param.theta_min = cos( 5 * pi/180);
    param.theta_max = cos(40 * pi/180);

   otherwise,  error('unknown model')
  end
  
%   param = myparams(param, varargin);

  % temporary run...
  if param.is_temp
    clk = clock;
    model = sprintf('%s_%02d-%02d-%02d%02d%02.0f', model, clk(2:6));
    dir = tempdir;
  end
  
  model = iff(param.ndiv == 1, model, sprintf('%s_%d-of-%d', model, param.div, param.ndiv));
  %seeds = signal2ga(S) > param.seed_GA & erode_mask(mask);
  seeds = loadsome('matlab', 'seeds_tc');
  %seeds = ismember(loadsome('matlab', 'seeds'), [3 4 5]);
  seeds = div_seeds(seeds, param.div, param.ndiv);
  ff = init(S, seeds, u, b, param);

  fn = sprintf('%s/%s.mat', dir, model)
  fn_= sprintf('%s/%s.bak.mat', dir, model); % backup
  
  n = numel(ff);
  backup_cnt = iff(param.is_temp, 0, ceil(param.backup*n));
  tic;
  for i = 1:n
    ff{i} = follow(S, u, b, mask, ff{i}, param);
    if ~mod(i,backup_cnt)
      fprintf('[%3.0f%%] (%7d - %7d) {%s}\n', 100*i/n, i, n, model);
      backup(fn_, ff, param, i);
    elseif param.is_temp
      fprintf('[%3.0f%%] (%7d - %7d) {%s}\n', 100*i/n, i, n, model);
    end
  end
  toc
  
  ff = map(@single, empty(ff));

  save(fn, 'ff', 'param', '-v7.3');
  disp(fn)
  system(['rm -f ' fn_]); % discard backup
  
  if nargout
    ff_ = ff;
  end
end
function backup(fn, ff, param, i)
  fn_tmp = [fn '.tmp'];
  save(fn_tmp, 'ff', 'param', 'i', '-v7.3');
  system(['mv ' fn_tmp ' ' fn]);
end
