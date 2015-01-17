param.display = true;

% SH params
u_ = icosahedron(4); % finer tessellation
fcs_ = convhulln(u_);
conn = FindConnectivity(fcs_, size(u_,1));
sh.L = 8;  sh.lambda = .006;  % Maxime

for b = 1000
  [tract u] = loadsome(sprintf('matlab_X_b%d_w', b), 'tract', 'u');
  [fibers_kf fibers_sh fibers_sh_F] = deal(cell(size(tract)));
  for i = 1:numel(tract)
    T = tract(i)
    fibers_kf{i} = follow2d_2tW(T.S, u, b, param);
    fibers_kf_ = filter_crossing(fibers_kf{i}, T.is_cross);
    xx = fibers_kf_{1}(1:2,:);
    [f s F] = fiber_2sh(T.S, xx, u, conn, T.th, sh.L, sh.lambda);
    fibers_sh{i} = f;
    fibers_sh_F{i} = F;
  end
  fn = sprintf('matlab_X_b%d_w_2TW', b);
  save(fn, 'fibers_kf', 'fibers_sh', 'fibers_sh_F');
end
