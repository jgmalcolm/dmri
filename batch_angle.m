function batch_angle(param)
  
  for b = 1000
    fn = sprintf('matlab_2cross_w_b%d', b);
    tract = loadsome(fn, 'tract');
    
    fn = [fn '_2T'];
    
    ff_kf = loadsome([fn '_KF'], 'ff');
    ff_sh = loadsome([fn '_SH'], 'f_sh');
    ff_lm = loadsome([fn '_LM'], 'ff');

    [e_kf e_sh e_lm] = deal(cell(size(tract)));
    for i = 1:numel(tract)
      T = tract(i);
      fprintf('A: b=%d  angle: %d  sigma: %.1f  w %.1f\n', b, T.th, T.sigma, T.w);
      ff_ = filter_crossing(ff_kf{i}, T.is_cross);
      e_kf{i} = angle_error(ff_,      T.th, T.w, param);
      e_sh{i} = angle_error(ff_sh{i}, T.th, T.w, param);
      e_lm{i} = angle_error(ff_lm{i}, T.th, T.w, param);
    end
    
    save([fn '_e'], 'e_sh', 'e_kf', 'e_lm');
  end
end
