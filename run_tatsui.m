function run_tatsui(div, ndiv)
% /projects/schiz/pi/tatsui/test_stochastic/spt-psts_resample_smallROI
% DWI  : caseD00815_DWI_resample.nhdr
% ROI1 : am_resample_roi07-08_s27_07.nhdr
% ROI2 : am_resample_roi07-08_s27_08.nhdr
  
  param.FA_min = .15;
  param.GA_min = .1;
  param.seeds = 3;
  param.voxel = [1 1 1];

  param.Qm = .001;
  param.Ql = 10;
  param.Rs = .02;
  
  % DTI --> can only run single-tensor
  model = '1T';
  follow = @follow3d_1t;  init = @init_fibers_1t;
  
  dir = '/home/malcolm/src/lmi/tatsui';
  [S u b mask] = loadsome([dir '/caseD00815'], 'S', 'u', 'b', 'mask');

  seeds = signal2ga(S) > .18 & erode_mask(mask);
  seeds = div_seeds(seeds, div, ndiv);
  ff = init(S, seeds, u, b, param);

  clk = clock;
  id = sprintf('%s-%s-%02d-%02d-%02d%02d%02.0f_%02d-of-%02d', model, 'tatsui', clk(2:6), div, ndiv)
  
  fn = sprintf('%s/%s.mat', dir, id);
  fn_= sprintf('%s/%s.bak.mat', dir, id); % backup
  
  n = numel(ff);
  for i = 1:n
    ff{i} = follow(S, u, b, mask, ff{i}, param);
    fprintf('[%3.0f%%] (%7d/%7d) {%s}\n', 100*i/n, i, n, id);
    if ~mod(i,10000), backup(fn_, ff, param, i); end % periodic backup
  end
  
  ff = connect(ff);
  ff = map(@single, empty(ff));

  disp(fn)
  save(fn, 'ff', 'param');
  system(['rm -f ' fn_]); % discard backup
end
function backup(fn, ff, param, i)
  fn_tmp = [fn '.tmp']
  save(fn_tmp, 'ff', 'param', 'i');
  system(['mv ' fn_tmp ' ' fn]);
end
