paths;

THETA = 0:5:90;
SIGMA = .1;
MODE = [false true];

n = numel(THETA) * numel(SIGMA) * numel(MODE);

u = icosahedron(2);

for b = [1000 3000]
  clear tract
  cur = 1;
  for sigma = SIGMA
    for th = THETA
      for m = MODE
      
        fprintf('%2d of %d [%3.0f%%]  b=%d  sigma %.1f  theta %d\n', ...
                cur, n, cur/n*100, b, sigma, th);

        S = gen_variety(u, th, sigma, m, b);
        tract(cur) = struct('sigma', sigma, ...
                            'th', th, ...
                            'mode', m, ...
                            'S', S);
        cur = cur + 1;
      end
    end
  end
  
  tract = reshape(tract, numel(MODE), numel(THETA), numel(SIGMA));

  fn = sprintf('matlab_variety_b%d', b);
  fprintf('saving %s...\n', fn);
  save(fn, 'tract', 'u', 'b');
end
