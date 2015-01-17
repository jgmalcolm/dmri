function batch_zoom_w

  sh.L = 8;  sh.lambda = .006;  % Maxime

  for b = 1000
    fn = sprintf('matlab_2cross_b%d_zoom', b);
    [T u] = loadsome(fn, 'T', 'u');
    ff_kf = loadsome([fn '_2T'], 'ff');
    ff_kf = double(ff_kf{1});
    
    xx = ff_kf(1:2,:);

    [F_kf M_kf] = deal([]);
    % KF
    for i = 1:size(ff_kf,2)
      X = ff_kf(3:end,i);
      [m1 l1 m2 l2] = state2tensor(X);
      f = tensor_odf([m1; l1],u,b) + tensor_odf([m2;l2],u,b);
      F_kf(:,i) = f / sum(f);
      M_kf(:,:,i) = [m1 m2];
    end
    
    % SH
    [f s F_sh] = fiber_2sh(T.S, xx, u, T.th, sh.L, sh.lambda);
    M_sh = reshape(f{1}(3:end,:), 3, 2, []);
    F_sh = F_sh{1};
    
    % LM

    save([fn '_2T_all'], 'F_kf', 'M_kf', 'F_sh', 'M_sh');
  end
