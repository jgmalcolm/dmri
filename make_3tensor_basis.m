function make_3tensor_basis(u, b, v)
  if ~exist('v','var'), v = u; end

  % 01045
%   lambda = {[1200  100] ...
%             [1100  200] ...
%             [1000 1000]};
%   lambda = {[1800  700] ...
%             [1800 1000] ...
%             [1800 1200]};

%   lambda = {[2200  600 2000 1000 1500 1500] ... % hi med none
%             [2200  900 1800 1100 1500 1500]};   % hi low none
  lambda = {[2200  900 2000 1000 2000 1000]};   % hi med med
  
  dirs = 1:size(v,1)/2;
  n = numel(dirs)^3*numel(lambda);

  U        = zeros(size(u,1), n, 'single');
  U_lookup = zeros(15, n);
  
  fprintf('generating %d combinations...\n', n);
  ct = 1;
  % for each direction
  for i = 1:length(dirs)
    m1 = v(dirs(i),:);
    for j = 1:length(dirs)
      m2 = v(dirs(j),:);
      for k = 1:length(dirs)
        m3 = v(dirs(k),:);
      
        % for each lambda
        for h = 1:numel(lambda)
          l1 = lambda{h}(1:2);
          l2 = lambda{h}(3:4);
          l3 = lambda{h}(5:6);
              
          X = [m1 l1 m2 l2 m3 l3]';
          s = model_3tensor_h(X, u, b);
          U(:,ct)        = s/norm(s);
          U_lookup(:,ct) = X;
          
          ct = ct + 1;
        end

      end
    end
  end
  
  %fn = sprintf('tensor_3fiber_01045');
  fn = sprintf('tensor_3fiber_brain0');
  fprintf('saving %s...\n', fn);
  save(fn, 'U', 'U_lookup');
end
