param.velocity = 1;
param.GA_min = .1;

param.k_min = .6;
param.theta_min = cos( 5 * pi/180);
%param.theta_max = cos(50 * pi/180);
%param.theta_min = cos(10 * pi/180);
param.theta_max = cos(40 * pi/180);

% original:
% Qk = .01;
% Qm = .001;
% Rs = .002;

param.Qk = .001;
param.Qm = .001;
param.Rs = .002;

clk = clock;
id = sprintf('%02d-%02d-%02d%02d%02.0f', clk(2:6))
err = mkdir([tempdir id]);

%seeds_ = seeds==20 | seeds==21;
seeds_ = seeds_tc;
%seeds_ = seeds_cc;
%seeds_ = (seeds_cortical==1024)|(seeds_cortical==2024);
%seeds_ = mask & signal2ga(S) > .21;

fn = sprintf('%s%s/%s', tempdir, id, id);
load watson_3fiber_01045
f_ = init_fibers_3w(S, seeds_, u, est_proj(U, U_lookup), param);
for i = 1:3
  [f f_] = follow3d_3w(S, u, mask, f_, param);
  ijk2vtk(fiber2ijk(f), [fn '_' int2str(i)]);
  save([tempdir id '/f_' int2str(i)], 'f', 'f_');
  if isempty(f_),  break; end
end

id
return
save([tempdir id '/matlab']);
