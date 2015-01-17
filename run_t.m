function run_t(seed_id)
  
  model = '2T';

  [S mask u b] = loadsome('matlab', 'S', 'mask', 'u', 'b');
  
  param.velocity = 1;
  param.GA_min = .1;
  param.len_min = 10;
  param.seeds = 20;
  param.ode = odeset('MaxStep', param.velocity/10);
  %param.voxel = [1.6667 1.6667 1.7];
  param.voxel = [1 1 2.6];

  param.w_min  = .3;
  param.FA_min = .15;
  param.theta_min = cos( 5 * pi/180);
  param.theta_max = cos(40 * pi/180);

  param.Qm = .001;
  param.Ql = 10;
  param.Qw = .01;
  param.Rs = .02;

  switch model
   case '2T',  follow = @follow3d_2t;  init = @init_fibers_2t;  str = '2T';
   case '3T',  follow = @follow3d_3t;  init = @init_fibers_3t;  str = '3T';
   case '2TW', follow = @follow3d_2tw; init = @init_fibers_2tw; str = '2TW';
   case '3TW', follow = @follow3d_3tw; init = @init_fibers_3tw; str = '3TW';
  end

  switch model  % model-specific parameters
   case '2TW'
    param.D = zeros(6,12); % non-negative weights and lambdas
    [param.D(1:3,4:6) param.D(4:6,10:12)] = deal(-eye(3));
    param.d = [0 0 -.2 0 0 -.2]';
    param.D_ = [0 0 0 0 0 1 0 0 0 0 0 1]; % w1 + w2 == 1
    param.d_ = 1;
   case '3TW'
    param.D = zeros(9,18); % non-negative weights and lambdas
    param.D(1:3,4:6) = -eye(3);
    param.D(4:6,10:12) = -eye(3);
    param.D(7:9,16:18) = -eye(3);
    param.d = -[0 0 w1 0 0 w2 0 0 w2]';
    param.D_ = zeros(1,18);
    param.D_([6 12 18]) = 1; % w1 + w2 + w3 == 1
    param.d_ = 1;
  end

  %%-- seeds
  switch seed_id
   case 'tc',     seeds = loadsome('matlab', 'seeds_tc');
   case 'cc',     seeds = loadsome('matlab', 'seeds_cc');
   case 'ic'
    seeds = loadsome('matlab', 'seeds');
    seeds = erode_mask(seeds==20|seeds==21);
   case '8-9'
    seeds = loadsome('matlab', 'seeds');
    seeds = erode_mask(seeds==8|seeds==9);
   case '16-17'
    seeds = loadsome('matlab', 'seeds');
    seeds = erode_mask(seeds==16|seeds==17);
   case 'ctx'
    seeds = loadsome('matlab', 'seeds_cortical');
    seeds = close_mask(1000<=seeds&seeds<=2034);
  end
  %seeds = false(size(mask)); seeds(73,73,29) = true; % case01045

  clk = clock;
  id = sprintf('%02d%02d%02d%02d%02.0f', clk(2:6))
  err = mkdir([tempdir id]);

  f0 = init(S, seeds, u, b, param);
  
  fn = sprintf('%s%s/%s', tempdir, id, id);
  for i = 1:3
    is_last = (i == 3);
    n = sum(cellfun(@(s) size(s,2), f0));
    [f f_] = deal(cell(1, n));
    j = 1;
    for X = f0
      for X = X{1}
        [f{j} f_{j}] = follow(S, u, b, mask, X, is_last, param);
        fprintf('%s-%d [%3.0f%%] (%5d/%5d) {%s}\n', str, i, 100*j/n, j, n, id);
        j = j + 1;
      end
    end
    ijk2tube(fiber2ijk(f), [fn '_' int2str(i)]);
    save([tempdir id '/f_' int2str(i)], 'f', 'f_', 'param');
    if isempty(f_), break, end
    f0 = f_;
    param.len_min = 0;
  end
  id
end
