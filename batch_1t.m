function batch_1t

  for b = 1000
    fn = sprintf('matlab_2cross_lambda_b%d', b);
    [tract u] = loadsome(fn, 'tract', 'u');
    
    ff = cell(size(tract));
    for i = 1:numel(tract)
      T = tract(i);
      fprintf('1T: b=%d   th %d  sigma %.1f  w %.1f \n', ...
              b, T.th, T.sigma, T.w);
      ff{i} = fiber_1t(T.S, T.is_cross, u, b);
    end
    save([fn '_1T'], 'ff');
  end

end
