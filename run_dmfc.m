function run_dmfc(model, div, ndiv)
  
  param.display = false;

  b = 1500;
  set = '3mm';

  dir = '/home/malcolm/src/lmi/dmfc';
  fn = sprintf('%s/dmfc_%s_b%04d', dir, set, b);
  
  [S u mask] = loadsome(fn, 'S', 'u', 'mask');
  
  % divide by baseline
  is_b0 = sum(u.^2,2) == 0;
  baseline = mean(S(:,:,:,is_b0), 4);
  S = S(:,:,:,~is_b0);
  S = S ./ (baseline(:,:,:,ones(1,size(S,4))) + eps);
  u = u(~is_b0,:);
  
  % "full-brain" seeding
  seeds = baseline > 200;
  seeds(:,:,[1 3]) = false;
 
  if param.display
    ga = signal2ga(S) .* mask;
    clf; imagesc(baseline(:,:,2)); axis image
  end
  
  u = [u; -u]; % HACK

  %%-- model functions
  switch model
   case '2TW',  follow = @follow_dmfc_2tw; init = @init_fibers_2tw;
   case '2T',   follow = @follow_dmfc_2t;  init = @init_fibers_2t;
   case '1T',   follow = @follow_dmfc_1t;  init = @init_fibers_1t;
  end
  
  param.seeds = 1;
  param.voxel = [2 2 2];

  param.GA_min = .01;
  param.FA_min = .01;
  param.w_min  = .3;
  
  % default SPL
  param.Qm = .001;
  param.Ql = 10;
  param.Qw = .01;
  param.Rs = .02;
  
  % for DMFC
  param.Qm = .01;
  param.Ql = 100;
  
  %%-- model parameters
  switch model
   case '2TW'
    param.D = zeros(6,12); % non-negative weights and lambdas
    [param.D(1:3,4:6) param.D(4:6,10:12)] = deal(-eye(3));
    param.d = [0 0 -.2 0 0 -.2]';
    param.D_ = [0 0 0 0 0 1 0 0 0 0 0 1]; % w1 + w2 == 1
    param.d_ = 1;
  end
    
  clk = clock;
  id = sprintf('%s-%02d-%02d-%02d%02d%02.0f_%02d-of-%02d', model, clk(2:6), div, ndiv)
  
  ff = init(S, seeds, u, b, param);
  
  fn = sprintf('%s/%s.mat', dir, id);
  fn_= sprintf('%s/%s.bak.mat', dir, id); % backup
  
  n = numel(ff);
  for i = 1:n
    ff{i} = follow(S, u, b, mask, ff{i}, param);
    fprintf('[%3.0f%%] (%d/%d) {%s}\n', 100*i/n, i, n, id);
  end

  ff = connect(ff);
  ff = map(@single, empty(ff));

  disp(fn)
  save(fn, 'ff', 'param');
end
