function run_fb(pid, model, div, ndiv)
% RUN_FB(PID,MODEL,DIV,NDIV) Begins a run
  addpath /home/malcolm/src
  addpath /home/malcolm/lib
  paths;
  
  [S u b mask] = load_patient(pid);
  seeds = signal2ga(S) > .18 & erode_mask(mask);

  param.backup = .05; % every xx% of progress
  param.FA_min = .15;
  param.GA_min = .1;
  param.seeds = 3;
  param.voxel = [1.66 1.66 1.70];

  param.Qm = .001;
  param.Ql = 10;
  param.Rs = .02;
  
  switch model
   case '3TW', follow = @follow3d_3tw; init = @init_fibers_3tw;
    param.Qw = .01;
    error('unfinished')
   case '2TW', follow = @follow3d_2tw; init = @init_fibers_2tw;
    param.Qw = .01;
    param.D = zeros(6,11);
    param.D(1:2,6) = [-1 1]; % w in [.2 .8]
    [param.D(3:4,4:5) param.D(5:6,10:11)] = deal(-eye(2));
    param.d = [-.2 .8 0 0 0 0]';
    param.D_ = [];
    param.d_ = [];
   case '2T',  follow = @follow3d_2t;  init = @init_fibers_2t;
   case '1T',  follow = @follow3d_1t;  init = @init_fibers_1t;
  end
  
  id = sprintf('%s-%05d_%02d-of-%02d', model, pid, div, ndiv)
  
  seeds = div_seeds(seeds, div, ndiv);
  ff = init(S, seeds, u, b, param);

  dir = '/home/malcolm/src/lmi/fb';
  fn = sprintf('%s/%s.mat', dir, id);
  fn_= sprintf('%s/%s.bak.mat', dir, id); % backup
  
  n = numel(ff);
  param.backup = ceil(param.backup*n)
  for i = 1:n
    ff{i} = follow(S, u, b, mask, ff{i}, param);
    fprintf('[%3.0f%%] (%7d - %7d) {%s}\n', 100*i/n, i, n, id);
    if ~mod(i,param.backup), backup(fn_, ff, param, i); end % periodic backup
  end
  
  ff = connect(ff);
  ff = map(@single, empty(ff));

  disp(fn)
  save(fn, 'ff', 'param', '-v7.3');
  system(['rm -f ' fn_]); % discard backup
end
function backup(fn, ff, param, i)
  fn_tmp = [fn '.tmp'];
  save(fn_tmp, 'ff', 'param', 'i', '-v7.3');
  system(['mv ' fn_tmp ' ' fn]);
end
