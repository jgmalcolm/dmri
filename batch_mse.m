function batch_mse

  for b = [1000]
    
    fn = sprintf('matlab_2cross_w_b%d', b);
    [tract u] = loadsome(fn, 'tract', 'u');

    S_clean = loadsome([fn '_clean'], 'S_clean');
    S_SH_clean = loadsome([fn '_SH_clean'], 'S_clean');
    fn = [fn '_2T'];
    f_kf = loadsome([fn '_KF'], 'ff');
    %f_pp = loadsome([fn '_PP'], 'fibers_pp');
    [f_sh S_sh] = loadsome([fn '_SH'], 'f_sh', 'S_sh');
    
    [mse_kf mse_pp mse_sh] = deal(cell(size(tract)));
    for i = 1:numel(tract)
      T = tract(i);
      fprintf('MSE: b=%d   th %d    sigma %.1f\n', b, T.th, T.sigma);
      f_kf_ = filter_crossing(f_kf{i}, T.is_cross);
      mse_kf{i} = mse_error(f_kf_,   S_clean{i}, u, b);
      %mse_pp{i} = mse_error(f_pp{i}, S_clean{i}, u, b);
      mse_sh{i} = mse_error(f_sh{i}, S_SH_clean{i}, u, b, S_sh{i});
    end
    
    save([fn '_mse'], 'mse_pp', 'mse_kf', 'mse_sh');
  end
end
