% run_synth

THETA = 15:5:90;
SIGMA = [.1 .2];

n = numel(THETA) * numel(SIGMA);

for b = [1000 3000]
  tract = [];
  cur = 1;
  for i = 1:numel(SIGMA)
    sigma = SIGMA(i);
    
    for j = 1:numel(THETA)
      th = THETA(j);
      
      fprintf('%2d of %d [%3.0f%%]  b=%d  sigma=%.1f  theta %d\n', ...
              cur, n, cur/n*100, b, sigma, th);

      [S F M u is_cross] = gen_3cross(th, sigma, 0, b);
      tract(i,j).sigma = sigma;
      tract(i,j).th = th;
      tract(i,j).S = S;
      tract(i,j).F = F;
      tract(i,j).M = M;
      tract(i,j).is_cross = is_cross;

      cur = cur + 1;
    end
  end

  fn = sprintf('matlab_3cross_b%d', b);
  fprintf('saving %s...\n', fn);
  save(fn, 'tract', 'u');
end
