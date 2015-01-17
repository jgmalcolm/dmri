paths;

%%-- normal block
THETA = 15:5:90;
SIGMA = .1;


%%-- single fiber crossing
% THETA = [40 50 60];
% SIGMA = .2;

n = numel(THETA) * numel(SIGMA) * numel(MODE);

u = icosahedron(2);

for b = [1000 3000]
  clear tract
  cur = 1;
  for i = 1:numel(SIGMA)
    sigma = SIGMA(i);
    
    for j = 1:numel(THETA)
      th = THETA(j);
      
      for k = 1:numel(MODE)
        m = MODE(k);
      
        fprintf('%2d of %d [%3.0f%%]  b=%d  sigma %.1f  theta %d\n', ...
                cur, n, cur/n*100, b, sigma, th);

        [S M is_cross] = gen_2cross(u, th, sigma, m, b);
        tract(cur) = struct('sigma', sigma, ...
                            'th', th, ...
                            'mode', m, ...
                            'S', S, 'M', M, ...
                            'is_cross', is_cross);
        cur = cur + 1;
      end
    end
  end
  
  tract = reshape(tract, numel(MODE), numel(THETA), numel(SIGMA));

  fn = sprintf('matlab_2cross_b%d_modes', b);
  fprintf('saving %s...\n', fn);
  save(fn, 'tract', 'u', 'b');
end
