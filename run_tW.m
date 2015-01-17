param.velocity = 1;
param.GA_min = .1;
param.len_min = 0;
param.seeds = 30;

param.w_min  = .3;
param.FA_min = .15;
param.theta_min = cos( 5 * pi/180);
param.theta_max = cos(50 * pi/180);

param.Qm = .001;
param.Ql = 10;
param.Qw = .01;
param.Rs = .02;

%-- positive eigenvalues, convex weights > .2
param.D = zeros(6,12); % non-negative weight and lambda
[param.D(1:3,4:6) param.D(4:6,10:12)] = deal(-eye(3));
param.d = [0 0 -.2 0 0 -.2]';
param.D_ = [0 0 0 0 0 1 0 0 0 0 0 1]; % w1 + w2 == 1
param.d_ = 1;

clk = clock;
id = sprintf('%02d%02d%02d%02d%02.0f', clk(2:6))
err = mkdir([tempdir id]);

% seeds_ = erode_mask(seeds==20 | seeds==21,3);
seeds_ = seeds_tc;
% seeds_ = mask2mid(seeds==3|seeds==4|seeds==5, .1);
% seeds_ = seeds_cc;
% seeds_ = false(size(seeds));
% seeds_(73,73,29) = true;

fn = sprintf('%s%s/%s', tempdir, id, id);
load tensor_2fiberW_01045

f0 = init_fibers_2tW(S, seeds_, u, est_proj(U, U_lookup), b, param);
id
for i = 1:2
  is_last = (i == 2);
  n = sum(cellfun(@(s) size(s,2), f0));
  [f f_] = deal(cell(1, n));
  j = 1;
  for X = f0
    for X = X{1}
      [f{j} f_{j}] = follow3d_2tW(S, u, b, mask, X, is_last, param);
      fprintf('2TW-%d  [%3.0f%%]  (%d of %d)  {%s}\n', i, 100*j/n, j, n, id);
      j = j + 1;
    end
  end
  ijk2vtk(fiber2ijk(f), [fn '_' int2str(i)]);
  save([tempdir id '/f_' int2str(i)], 'f', 'f_', 'param');
  if isempty(f_), break, end
  f0 = f_;
  param.len_min = 0;
end

id
