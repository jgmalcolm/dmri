function run_0(varargin)
% RUN_0(DIV,NDIV) Begins a run
% -- RUN_0(ID) Resumes a run

  switch nargin
   case 1
    error('unfinished');
    id = varargin{1};
   case 2
    div = varargin{1};
    ndiv = varargin{2};
  end

  [S u b] = loadsome('brain0', 'S', 'u', 'b');
  u = [u;-u]; % HACK

  b0 = loadsome('brain0_roi', 'brain0_brainmaskonB0Anz');
  mask = b0 >  0;

  param.velocity = 1;
  param.FA_min = .15;
  param.GA_min = .1;
  param.len_min = 3;
  param.seeds = 1;
  param.close = 0;
  param.ode = odeset('MaxStep', param.velocity/10);
  param.voxel = [2 2 2];

  param.Qm = .001;
  param.Ql = 10;
  param.Rs = .02;
  
  clk = clock;
  id = sprintf('%02d-%02d-%02d%02d%02.0f_%02d-of-%02d', clk(2:6), div, ndiv)
  % seeds = false([128 128 68]); seeds(63,65,33) = true; % brain0
  % seeds = b0 > 90;
  seeds = b0 > 100;

  seeds = div_seeds(seeds, div, ndiv);
  ff = init_fibers_2t(S, seeds, u, b, param);

  dir = '/home/malcolm/src/lmi/brain0/';
  fn = sprintf('%s%s', dir, id);
  
  n = numel(ff);
  for i = 1:n
    ff{i} = follow3d_2t(S, u, b, mask, ff{i}, param);
    fprintf('2T [%3.0f%%] (%d/%d) {%s}\n', 100*i/n, i, n, id);
  end
  
  ff = connect(ff);
  ff = map(@single, empty(ff));

  disp(fn)
  save(fn, 'ff', 'param');
end
