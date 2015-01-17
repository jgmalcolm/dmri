function run_pbc_resume(pid, div, ndiv)
% RUN_PBC_RESUME(PID,DIV,NDIV) Resume a run
  paths;
  
  model = '2T';
  follow = @follow3d_2t;  init = @init_fibers_2t;
  
  dir = '/home/malcolm/src/lmi/pbc';
  [S u b] = loadsome([dir '/' pid], 'S', 'u', 'b');
  u = [u;-u]; % HACK
  
  b0 = loadsome([dir '/' pid '_roi'], 'brainmaskonB0Anz');
  mask = b0 >  0;

  id = sprintf('%s_%d-of-%d', pid, div, ndiv)

  % find patient's file
  fn = sprintf('%s/%s.mat', dir, id);
  fn_= sprintf('%s/%s.bak.mat', dir, id); % backup
  
  % load in patient
  [ff param i] = loadsome(fn_, 'ff', 'param', 'i');

  n = numel(ff);
  param.backup = .05; % every xx% of progress
  param.backup = ceil(param.backup*n);
  for i = i+1:n
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
