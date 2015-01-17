function run_pbc(pid, div, ndiv)
% RUN_PBC(PID,DIV,NDIV) Begins a run
  paths;
  
  dir = '/home/malcolm/src/lmi/pbc';
  [S u b] = loadsome([dir '/' pid], 'S', 'u', 'b');
  u = [u;-u]; % HACK

  b0 = loadsome([dir '/' pid '_roi'], 'brainmaskonB0Anz');
  mask = b0 >  0;

  param.backup = .05; % every xx% of progress
  param.FA_min = .15;
  param.GA_min = .1;
  param.seeds = 1;
  param.voxel = [2 2 2];

  param.Qm = .001;
  param.Ql = 10;
  param.Rs = .02;
  
  follow = @follow3d_2t; init = @init_fibers_2t;

  id = sprintf('%s_%d-of-%d', pid, div, ndiv)

  seeds = b0 > 100;
  seeds = div_seeds(seeds, div, ndiv);

  ff = init(S, seeds, u, b, param);

  fn = sprintf('%s/%s.mat', dir, id);
  fn_= sprintf('%s/%s.bak.mat', dir, id); % backup
  
  n = numel(ff);
  param.backup = ceil(param.backup*n);
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
