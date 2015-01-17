function [X_i X_c] = batch_fibers_register(X)
  ref = 1; % reference patient

  %%-- coarse register
  X_c = X;
  for i = 1:3
    X_c(:,i) = coarse_registration(X(:,i), ref);
  end
  
  %%-- ICP refinement
  X_i = X_c;
  for i = 1:3
    x_ref = down(X_i{ref,i});
    for j = setxor(ref, 1:size(X,1));  % all except reference
      fprintf('ICP label %d   subject %d  ', i, j);
      x_j = down(X_i{j,i});
      if isempty(x_j), disp(' '); continue, end
      [R T] = icp(x_ref, x_j, 20);
      X_i{j,i} = center(R*X_i{j,i}, -T); % apply
    end
    %save(sprintf('lmi/fa/points_r%02d_50k',i), 'X_i');
  end
end


function x_ = down(x)
  x = double(unique(x','rows')');
  inc = floor(size(x,2)/50e3);  % desire 2k points
  x_ = x(:,1:inc:end);
  if isempty(x_)
    x_ = x;
  end
end
