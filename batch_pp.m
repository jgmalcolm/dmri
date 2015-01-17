function batch_pp
  for b = [1000 3000]
    fn = sprintf('tensor_2fiberW_b%d', b);
    [U U_lookup] = loadsome(fn, 'U', 'U_lookup');
    proj = est_proj(U, U_lookup);

    fn = sprintf('matlab_2cross_w_b%d', b);
    [tract u] = loadsome(fn, 'tract', 'u');

    ff = cell(size(tract));
    for i = 1:numel(tract)
      T = tract(i);
      fprintf('PP: b=%d   th %d   sigma %.1f\n', b, T.th, T.sigma);
      ff{i} = fiber_pp(T.S, T.is_cross, u, proj);
    end

    save([fn '_2TW_PP'], 'ff');
  end
end
