function batch_fixed_angle
  run_tw_synth
  
  for b = [1000]
    fn = sprintf('matlab_3cross_w_b%d', b);
    [tract] = loadsome(fn, 'tract', 'u');
    
    fn = [fn '_3TW'];

    ff_kf = loadsome([fn '_KF'], 'ff');
    ff_sh = loadsome([fn '_SH'], 'f_sh');

    [e_kf e_sh] = deal(cell(size(tract)));
    
    th = pi; %% FIX

    for i = 1:numel(tract)
      T = tract(i);
      fprintf('A: b=%d  angle: %d  sigma: %.1f\n', b, th, T.sigma);
      ff_ = filter_crossing(ff_kf{i}, T.is_cross);
      e_kf{i} = angle_error(ff_,      T.M, param);
      e_sh{i} = angle_error(ff_sh{i}, T.M, param);
    end
    
    save([fn '_e'], 'e_sh', 'e_kf');
  end
end
