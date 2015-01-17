THETA = 15:5:90;
SIGMA = .2;
W = 1/3;
lambda = [1200 100 100];

n = numel(THETA) * numel(SIGMA) * numel(W);

u = icosahedron(2);
% u = icosampling(2);

for b = [1000]
  clear tract
  cur = 1;
  for i = 1:numel(SIGMA)
    sigma = SIGMA(i);
    
    for j = 1:numel(THETA)
      th = THETA(j);
      
      for k = 1:numel(W)
        w = W(k);

        fprintf('%2d of %d [%3.0f%%]  b=%d  sigma %.1f  theta %d  w %.1f\n', ...
                cur, n, cur/n*100, b, sigma, th, w);
        
        [S is_cross] = gen_3cross_w(u, th, w, sigma, 0, b, lambda);
        tract(cur) = struct('sigma', sigma, ...
                            'th', th, ...
                            'w', w, ...
                            'S', S, ...
                            'lambda', lambda, ...
                            'is_cross', is_cross);
        cur = cur + 1;
      end
    end
  end
  
  tract = reshape(tract, numel(W), numel(THETA), numel(SIGMA));

  fn = sprintf('matlab_3cross_w_b%d', b);
  fprintf('saving %s...\n', fn);
  save(fn, 'tract', 'u', 'b');
end
