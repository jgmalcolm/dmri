function run_branch(model, varargin)
% RUN_BRANCH(MODEL) Begins a run on case01045
% RUN_BRANCH(MODEL,'div', 1, 'ndiv', 4) Part one of four.
% RUN_BRANCH(MODEL, 'is_temp', true)  Temporary run.
  paths;
  
  dir = '/home/malcolm/src/lmi/tensor_TMI';
  param.backup = .05; % every xx% of progress
  
  try
    [S mask u b] = evalin('caller', 'deal(S,mask,u,b)');
  catch
    [S mask u b] = loadsome('matlab', 'S', 'mask', 'u', 'b');
  end

  param.FA_min = .15;
  param.GA_min = .1;
  param.seeds = 15;
  param.seed_GA = .18;
  param.voxel = [1.66 1.66 1.70];

  param.max_len = 250;
  param.min_rad_curv = 0.87;

  param.is_temp = false;
  param.ndiv = 1;
  param.div  = 1;
  
  param.P0 = nan;
  param.dt = .3;
  param.lm.lb = [-inf -inf -inf 100 100 -inf -inf -inf 100 100];
  param.lm.ub = [ inf  inf  inf inf inf  inf  inf  inf inf inf];
  param.theta_min = cos( 5 * pi/180);
  param.theta_max = cos(40 * pi/180);

  switch model
   case 'LMi', follow = @follow_lm_i; init = @init_fibers_2t;
   case 'LMc', follow = @follow_lm_c; init = @init_fibers_2t;
   otherwise,  error('unknown model')
  end
  
  param = myparams(param, varargin);

  % temporary run...
  if param.is_temp
    clk = clock;
    model = sprintf('%s_%02d-%02d-%02d%02d%02.0f', model, clk(2:6));
    dir = tempdir;
  end
  
  model = iff(param.ndiv == 1, model, sprintf('%s_%d-of-%d', model, param.div, param.ndiv));
  %seeds = signal2ga(S) > param.seed_GA & erode_mask(mask);
  seeds = loadsome('matlab', 'seeds_tc');
  %seeds = loadsome('matlab', 'seeds') == 4;
  seeds = div_seeds(seeds, param.div, param.ndiv);

  f0 = init(S, seeds, u, b, param);
  
  for i = 1:3
    is_last = (i == 3);
    n = sum(cellfun(@(s) size(s,2), f0));

    [f f_] = deal(cell(1,n));
    j = 1;
    for X = f0
      for X = X{1}
        [f{j} f_{j}] = follow(S, u, b, mask, X, param, is_last);
        fprintf('%d [%3.0f%%] (%7d - %7d) {%s}\n', i, 100*j/n, j, n, model);
        j = j + 1;
      end
    end

    fn = sprintf('%s/%s_%d', dir, model, i)
    write(fn, f, f_, param);
    ijk2tube(f, fn);

    if isempty(f_), break, end
    f0 = f_;
  end
  
  disp(fn)
end
function write(fn, ff, ff_, param)
  ff  = map(@single, empty(ff));
  ff_ = map(@single, empty(ff_));
  
  fn = [fn '.mat'];
  fn_tmp = [fn '.tmp'];
  save(fn_tmp, 'ff', 'ff_', 'param', '-v7.3');
  system(['mv ' fn_tmp ' ' fn]);
end
