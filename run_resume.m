function run_resume(model, div, ndiv)
% RUN_RESUME(MODEL,DIV,NDIV) Resumes run on case01045
  paths;
  
  % find patient's file
  dir_ = '/home/malcolm/src/lmi/tmi';
  d = dir(sprintf('%s/%s_%d-of-%d.bak.mat', dir_, model, div, ndiv));
  assert(numel(d) == 1)
  id = d(1).name(1:end-8);
  fn = sprintf('%s/%s.mat',     dir_, id);
  fn_= sprintf('%s/%s.bak.mat', dir_, id) % backup
  
  % load in patient
  [ff param i] = loadsome(fn_, 'ff', 'param', 'i');
  [S mask u b] = loadsome('matlab', 'S', 'mask', 'u', 'b');

  switch model
   case '1T', follow = @follow3d_1t;    init = @init_fibers_1t;
   case '2T', follow = @follow3d_2t;    init = @init_fibers_2t;
   case 'LM', follow = @follow3d_2t_lm; init = @init_fibers_2t; param.P0 = nan;
   otherwise,  error('unfinished')
  end
  
  model = iff(param.ndiv == 1, model, sprintf('%s_%d-of-%d', model, param.div, param.ndiv));

  n = numel(ff);
  backup_cnt = iff(param.backup < 1, ceil(param.backup*n), param.backup)
  for i = i+1:n
    ff{i} = follow(S, u, b, mask, ff{i}, param);
    if ~mod(i,backup_cnt)
      fprintf('[%3.0f%%] (%7d - %7d) {%s}\n', 100*i/n, i, n, model);
      backup(fn_, ff, param, i);
    end
  end
  param.time = nan; % not available since resumed
  ff = map(@single, empty(ff));

  save(fn, 'ff', 'param', '-v7.3');
  disp(fn)
  system(['rm -f ' fn_]); % discard backup
end
function backup(fn, ff, param, i)
  fn_tmp = [fn '.tmp'];
  save(fn_tmp, 'ff', 'param', 'i', '-v7.3');
  system(['mv ' fn_tmp ' ' fn]);
end
