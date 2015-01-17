THETA_TH = 0:5:90;
THETA_FA = [0 45 90];
SIGMA = .2;
L2 = 100:50:900;


for b = [1000]
  n =     numel(THETA_TH) * numel(SIGMA);
  n = n + numel(THETA_FA) * numel(L2);
  cur = 1;
  clear tract; tract(n).S = nan;

  %% vary angle
  for sigma = SIGMA
    for th = THETA_TH
      fprintf('%2d of %d [%3.0f%%]  b=%d  sigma %.1f  theta %d\n', ...
              cur, n, cur/n*100, b, sigma, th);

      [S F M u is_cross] = gen_2cross(th, sigma, 0, b);
      tract(cur).sigma = sigma;
      tract(cur).th = th;
      tract(cur).l2 = 100;
      tract(cur).S = S;
      tract(cur).F = F;
      tract(cur).M = M;
      tract(cur).is_cross = is_cross;

      cur = cur + 1;
    end
  end
  
  sigma = 0.2;

  %% vary lambda_2
  for th = THETA_FA
    for l2 = L2
      fprintf('%2d of %d [%3.0f%%]  b=%d  theta %d  lambda %d\n', ...
              cur, n, cur/n*100, b, th, l2);
      
      lambda = [1200 l2 l2];
      [S F M u is_cross] = gen_2cross(th, sigma, 0, b, lambda);
      tract(cur).sigma = sigma;
      tract(cur).th = th;
      tract(cur).l2 = l2;
      tract(cur).S = S;
      tract(cur).F = F;
      tract(cur).M = M;
      tract(cur).is_cross = is_cross;

      cur = cur + 1;
    end
  end

  fn = sprintf('matlab_2cross_fa_b%d', b);
  fprintf('saving %s...\n', fn);
  save(fn, 'tract', 'u', 'b');
end
