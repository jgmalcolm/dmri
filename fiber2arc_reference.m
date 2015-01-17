function [u v] = fiber2arc_reference(ff, eig)
  
  % prepare arc-length reference frame  
  xx = [ff{:}];
  xx = xx(1:3,:)';
  u = mean(xx); % center
  [U V] = svd(cov(xx));
  v = U(:,eig)'; % reference eigenvector
end
