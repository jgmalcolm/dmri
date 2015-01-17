function make_2tensor_basis(u, b, v)
  if ~exist('v','var'), v = u; end

  % synthetic
%   lambda = {[1700  200] ...
%             [1500 1500] ...
%             [1200  100]};
  lambda = {[1200  100]};

  % 01045
%   lambda = {[1200  100] ...
%             [1100  200] ...
%             [1000 1000]};
%   lambda = {[1800  700] ...
%             [1800 1000] ...
%             [1800 1200]};
%   lambda = {[2200  900] ...
%             [2000 1000] ...
%             [1800 1100]};
  
  dirs = 1:size(v,1)/2;
  n = numel(dirs)^2*sum(1:numel(lambda));

  U        = zeros(size(u,1), n, 'single');
  U_lookup = zeros(10, n);
  
  fprintf('generating %d combinations...\n', n);
  ct = 1;
  % for each direction
  for i = 1:length(dirs)
    m1 = v(dirs(i),:);
    for j = 1:length(dirs)
      m2 = v(dirs(j),:);
      
      % for each lambda
      for k = 1:numel(lambda)
        l1 = lambda{k};
        for h = k:numel(lambda)
          l2 = lambda{h};
          
          X = [m1 l1 m2 l2]';
          s = model_2tensor_h(X, u, b);
          U(:,ct)        = s/norm(s);
          U_lookup(:,ct) = X;
          
          ct = ct + 1;
        end
      end
      
    end
  end
  
  fn = sprintf('tensor_2fiber_b%d', b);
  %fn = sprintf('tensor_2fiber_brain0');
  fprintf('saving %s...\n', fn);
  save(fn, 'U', 'U_lookup');
end
