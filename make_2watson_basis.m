function [U U_lookup] = make_2watson_basis(u, b, v)
  if ~exist('v','var'), v = u; end

  scale = {[ .1  .1] ...
           [1.2 1.3] ...
           [2   2.1] ...
           [1.3  .1]};
  
  % for high b-values
  if b > 1500
    for h = 1:length(scale)
      scale{h} = scale{h}*2;
    end
  end

  dirs = 1:size(v,1)/2;
  n = numel(dirs)^2*numel(scale);
  fprintf('generating %d combinations...\n', n);
  U_lookup = zeros(8,n);
  U        = zeros(size(u,1),n,'single');

  ct = 1;
  for i = 1:length(dirs)
    m1 = v(dirs(i),:);
    
    for j = 1:length(dirs)
      m2 = v(dirs(j),:);
      
      for h = 1:length(scale)
        k1 = scale{h}(1);
        k2 = scale{h}(2);
        
        X = [m1 k1 m2 k2]';
        U(:,ct) = model_2watson_h(X, u);

        U_lookup(:,ct) = X;
        
        ct = ct + 1;
      end
      
    end    
  end

  fn = sprintf('watson_2fiber_b%d', b);
  %fn = sprintf('watson_2fiber_01045');
  fprintf('saving %s...\n', fn);
  save(fn, 'U', 'U_lookup');
end
