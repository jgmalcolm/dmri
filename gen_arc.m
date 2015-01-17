function S = gen_arc(u, b, sigma)
% sigma - noise level (0, 0.1, 0.2)
  paths;
  
  lambda = [1200 100 100];

  d_iso = 1e-6*diag([1500 1500 1500]);
  d_aniso = 1e-6*diag(lambda);

  k = size(u,1); % sample directions
  
  n = 15;
  S = zeros(n*n, k); % ADC signal

  [xx yy] = ndgrid(1:n);
  
  is_iso = true(size(xx));

  cx = 8; cy = 7; rad = 5.5;
  %%-- arc
  d = (xx - cx).^2 + (yy - cy).^2;
  is_path = (rad-3)^2 < d & d < (rad+3)^2 & yy >= cy;
  [x y] = find(is_path);
  [x y] = deal(y-cy, -(x-cx));
  V = [x(:) y(:)]; V(:,3) = 0;
  D = tensors(V, d_aniso);
  S(is_path,:) = tensor2signal(D, u, b);
  is_iso(is_path) = false;

  %%-- crossover
  if 0
  is_path = is_path & (7 <= xx & xx <= 9);
  [x y] = find(is_path);
  [x y] = deal(0*x, y);
  V = [x(:) y(:)]; V(:,3) = 0;
  D = tensors(V, d_aniso);
  S(is_path,:) = (S(is_path,:) + tensor2signal(D, u, b))/2;
  end
  

  %%-- straight legs
  is_top = xx <= 5;
  is_bot = 11 <= xx;
  is_path = yy <= cy+1 & (is_top | is_bot);
  [x y] = find(is_path);
  [x y] = deal(0*x, y);
  V = [x(:) y(:)]; V(:,3) = 0;
  D = tensors(V, d_aniso);
  S(is_path,:) = tensor2signal(D, u, b);
  is_iso(is_path) = false;
  
  %%-- crossover
  if 0
  is_cross = is_path & (12 <= yy & yy <= 17);
  [x y] = find(is_cross);
  [x y] = deal(x, 0*y);
  V = [x(:) y(:)]; V(:,3) = 0;
  D = tensors(V, d_aniso);
  S(is_cross,:) = (S(is_cross,:) + tensor2signal(D, u, b))/2;
  
  is_ramp = is_path & (11 == yy | yy == 18);
  [x y] = find(is_ramp);
  [x y] = deal(x, 0*y);
  V = [x(:) y(:)]; V(:,3) = 0;
  D = tensors(V, d_aniso);
  S(is_ramp,:) = (4*S(is_ramp,:) + 2*tensor2signal(D, u, b))/6;

  is_ramp = is_path & (10 == yy | yy == 19);
  [x y] = find(is_ramp);
  [x y] = deal(x, 0*y);
  V = [x(:) y(:)]; V(:,3) = 0;
  D = tensors(V, d_aniso);
  S(is_ramp,:) = (5*S(is_ramp,:) + tensor2signal(D, u, b))/6;
  end  


  %%-- isotropic
  [x y] = find(is_iso);
  V = [x(:) y(:)]; V(:,3) = 0;
  D = tensors(V, d_iso);
  S(is_iso,:) = tensor2signal(D, u, b);
  
  % normalize
  if sigma
    randn('state', 0); % introducing...determinism!
    for i = 1:size(S,1)
      s = S(i,:);
      x = sigma * mean(s) * randn(size(s));
      y = sigma * mean(s) * randn(size(s));
      S(i,:) = sqrt((s + x).^2 + y.^2);
    end
  end

  % finalize
  S = reshape(S, n, n, k);
end
