THETA = [0 45 90];
sigma = .2;
W = [.5 .6 .7];
lambda1 = 1200;
LAMBDA2 = 100:100:700;

n = numel(LAMBDA2) * numel(THETA) * numel(W);

u = icosahedron(2);

for b = [1000]
  clear tract
  cur = 1;
  for i = 1:numel(LAMBDA2)
    lambda2 = LAMBDA2(i);
    
    for j = 1:numel(THETA)
      th = THETA(j);
      
      for k = 1:numel(W)
        w = W(k);

        fprintf('%2d of %d [%3.0f%%]  b=%d  sigma %.1f  theta %d  w %.1f  lambda [%d %d %d]\n', ...
                cur, n, cur/n*100, b, sigma, th, w, lambda1, lambda2, lambda2);
        
        lambda = [lambda1 lambda2 lambda2];
        [S is_cross] = gen_2cross_w(u, th, w, sigma, 0, b, lambda);
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
  
  tract = reshape(tract, numel(W), numel(THETA), numel(LAMBDA2));

  fn = sprintf('matlab_2cross_lambda_b%d', b);
  fprintf('saving %s...\n', fn);
  save(fn, 'tract', 'u', 'b');
end
