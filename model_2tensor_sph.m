function [f_fn h_fn] = model_2tensor_sph(u, b)
  f_fn = @model_2tensor_sph_f; % identity, but fix up state
  h_fn = @(X) model_2tensor_sph_h(X,u,b);
  %h_fn = @h;
  
  function s = h(X)
    clf
    sp(2,2,1); show_X(X);
    title('h');
    
    s = model_2tensor_sph_h(X,u,b);
    sp(2,2,2); show_s(s(:,1),X(:,1),u);
    for i = 1:16
      sp(4,8,2*8+i); show_s(s(:,i+1),X(:,i+1),u);
    end
    keyboard
  end
end

function show_s(s, X, u)
  M = [s2c(X(1:2))  s2c(X(5:6))];
  odf_axes(s, u, M, [0 0 0]', 'r');
  axis image off
end

function show_X(X)
  m1 = zeros(3,size(X,2)); m2 = m1;
  for i = 1:size(X,2);
    m1(:,i) = s2c(X(1:2,i));
    m2(:,i) = s2c(X(5:6,i));
  end
  plot3(m1(1,:),m1(2,:),m1(3,:),'g.', ...
        m1(1),m1(2),m1(3),'ro', ...
        m2(1,:),m2(2,:),m2(3,:),'y.', ...
        m2(1),m2(2),m2(3),'bs', ...
        [0 1],[0 0],[0 0],'r', ...
        [0 0],[0 1],[0 0],'y', ...
        [0,0],[0 0],[0 1],'b', 'MarkerSize', 20);
  set(gca, 'XLim', [-1 1], 'YLim', [-1 1], 'ZLim', [-1 1]);
  view(2)
  rotate3d on
end
