function sim2file(K, fn)
  fid = fopen(fn, 'w');
  n = length(K);
  for c = 1:n
    for r = 1:n
      if K(r,c)
        fprintf(fid, '%d %d %f\n', r, c, K(r,c));
      end
    end
  end
  fclose(fid);
end
