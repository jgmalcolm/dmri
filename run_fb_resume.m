function run_fb_resume(pid, model, div, ndiv)
% RUN_FB_RESUME(PID,MODEL,DIV,NDIV) Resume a run
  paths;

  switch model
   case '2T',  follow = @follow3d_2t;  init = @init_fibers_2t;
   case '1T',  follow = @follow3d_1t;  init = @init_fibers_1t;
  end
  
  % find patient's file
  fbdir = '/home/malcolm/src/lmi/fb';
  d = dir(sprintf('%s/%s-%05d*_%02d-of-%02d.bak.mat', fbdir, model, pid, div, ndiv));
  assert(numel(d) == 1)
  id = d(1).name(1:end-8);
  fn = sprintf('%s/%s.mat', fbdir, id);
  fn_= sprintf('%s/%s.bak.mat', fbdir, id) % backup
  
  % load in patient
  [ff param i] = loadsome(fn_, 'ff', 'param', 'i');
  [S u b mask] = load_patient(pid);

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
