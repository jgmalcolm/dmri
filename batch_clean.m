function batch_clean
  for b = [1000]
    fn = sprintf('matlab_2cross_w_b%d', b);
    [tract b] = loadsome(fn, 'tract', 'b');
    S_clean = cell(size(tract));
    u = icosampling(2);
    n = numel(tract);
    for i = 1:n
      T = tract(i);
      fprintf('%2d of %d [%3.0f%%]  b=%d  theta %d\n', i, n, i/n*100, b, T.th);
      S_clean{i} = gen_2cross_w(u, T.th, T.w, 0, 0, b);
      %S_clean{i} = gen_2cross(T.th, 0, 0, b);
    end
    save([fn '_SH_clean'], 'S_clean');
  end
end
