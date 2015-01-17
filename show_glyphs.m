function show_glyphs(GA, fibers)
  colormap gray; cla; imagesc(GA); axis image;
  hold on;
  cellfun(@(f)plot_2t(f), fibers);
  hold off;
end

function plot_2t(f)
  f = double(f);
  for f = f
    x = f(1:2);
    [m1 l1 m2 l2] = state2tensor(f(3:12));
    m1 = x*[1 1] + m1(1:2)*[1 -1]/2;
    m2 = x*[1 1] + m2(1:2)*[1 -1]/2;
    plot(m1(2,:), m1(1,:), 'b', ...
         m2(2,:), m2(1,:), 'r', 'LineWidth', 3);
  end
end

function plot_1t(f)
  f = double(f);
  for f = f
    x = f(1:2);
    [m1 l1] = state2tensor(f(3:7));
    m1 = x*[1 1] + m1(1:2)*[1 -1]/2;
    plot(m1(2,:), m1(1,:), 'b', 'LineWidth', 1.5);
  end
end

function plot_fiber_hot(f,param)
  if isempty(f), return, end
  plot(f(2,:), f(1,:), 'r', 'LineWidth', 1.5);
  for f = f
    x = f(1:2);
    [m1 w1 k1 m2 w2 k2] = state2hot(f(3:12));
    m1 = m1(1:2); m2 = m2(1:2);
    if true || is_two && is_branching
      e1 = abs([1 0] * m1); e2 = abs([1 0] * m2);
      if e1 <= e2
        X = x*[1 1] + m1*[1 -1]/2;
      else
        X = x*[1 1] + m2*[1 -1]/2;
      end
      plot(X(2,:), X(1,:), 'b', 'LineWidth', 1.5);
    end
  end

  function [m1 w1 k1 m2 w2 k2] = state2hot(X)
    m1 = X(1:3); m1 = m1 / norm(m1);
    w1 = X(4);
    k1 = X(5);
    m2 = X(6:8); m2 = m2 / norm(m2);
    w2 = X(9);
    k2 = X(10);
  end
end
function plot_fiber_2T(f,param)
  if isempty(f), return, end
  FA = param.FA_min;
  tmin = param.theta_min; tmax = param.theta_max;
  plot(f(2,:), f(1,:), 'r', 'LineWidth', 1.5);
  for f = f
    x = f(1:2);
    [m1 l1 m2 l2] = state2tensor(f(3:12));
    m1 = m1(1:2); m2 = m2(1:2);
    is_two = l2fa(l1) > FA && l2fa(l2) > FA;
    th = abs(m1'*m2);
    is_branching = th < tmin && th > tmax;
    if is_two && is_branching
      e1 = abs([1 0] * m1); e2 = abs([1 0] * m2);
      if e1 <= e2
        X = x*[1 1] + m1*[1 -1]/2;
      else
        X = x*[1 1] + m2*[1 -1]/2;
      end
      plot(X(2,:), X(1,:), 'b', 'LineWidth', 1.5);
    end
  end
end


function plot_fiber_2w(f, param)
  if isempty(f), return, end
  plot(f(2,:), f(1,:), 'r', 'LineWidth', 2);
  x_ = f(1:2,1); % save past position
  for f = f
    x = f(1:2);
    [m1 k1 m2 k2] = state2watson(f(3:10));
    m1 = m1(1:2); m2 = m2(1:2);
    
    is_branch = abs(m1'*m2) < cos(15*pi/180);
    is_two = k1 > param.k_min && k2 > param.k_min;
    if is_two && is_branch
      dx = x - x_;
      e1 = abs(dx' * m1); e2 = abs(dx' * m2);
      if e1 < e2
        X = x([1 1;2 2]) + m1*[1 -1]/2;
      else
        X = x([1 1;2 2]) + m2*[1 -1]/2;
      end
      plot(X(2,:), X(1,:), 'b', 'LineWidth', 2);
    end
  end
end


function plot_fiber_3w(f, param)
  if isempty(f), return, end
  plot(f(2,:), f(1,:), 'b', 'LineWidth', 1.5);
  x_ = f(1:2,1); % save past position
  for f = f
    x = f(1:2);
    [m1 k1 m2 k2 m3 k3] = state2watson(f(3:end));
    m1 = m1(1:2); m2 = m2(1:2); m3 = m3(1:2);
    
    X = x([1 1;2 2]) + m1*[1 -1]/2;
    if k1 > param.k_min
      plot(X(2,:), X(1,:), 'r', 'LineWidth', 1.5);
    end
    X = x([1 1;2 2]) + m2*[1 -1]/2;
    if k2 > param.k_min
      plot(X(2,:), X(1,:), 'r', 'LineWidth', 1.5);
    end
    if k3 > param.k_min
      X = x([1 1;2 2]) + m3*[1 -1]/2;
      plot(X(2,:), X(1,:), 'r', 'LineWidth', 1.5);
    end
  end
end


function plot_fiber_2TW(f,param)
  if isempty(f), return, end
  FA = param.FA_min;
  T = param.theta_min;
  plot(f(2,:), f(1,:), 'r', 'LineWidth', 1.5);
  for f = f
    x = f(1:2);
    [m1 l1 w1 m2 l2 w2] = state2tensorW(f(3:end));
    m1 = m1(1:2); m2 = m2(1:2);
    is_A = l2fa(l1) > FA && w1 > param.w_min;
    is_B = l2fa(l2) > FA && w2 > param.w_min;
    is_two = is_A && is_B;
    is_branching = abs(m1' * m2) < T;
    if is_two && is_branching
      e1 = abs([1 0] * m1); e2 = abs([1 0] * m2);
      if e1 <= e2
        X = x*[1 1] + m1*[1 -1]/2;
      else
        X = x*[1 1] + m2*[1 -1]/2;
      end
      plot(X(2,:), X(1,:), 'k', 'LineWidth', 1.5);
    end
  end
end
function plot_2TW_glyphs(f,param)
  if isempty(f), return, end
  FA = param.FA_min;
  T = param.theta_min;
  for f = f
    x = f(1:2);
    [m1 l1 w1 m2 l2 w2] = state2tw(f(3:end));
    m1 = m1(1:2); m2 = m2(1:2);
    is_A = l2fa(l1) > FA && w1 > param.w_min;
    is_B = l2fa(l2) > FA && w2 > param.w_min;
    is_two = is_A && is_B;
    is_branching = abs(m1' * m2) < T;
    if is_two && is_branching
      o1 = x*[1 1] + m1*[1 -1]/2;
      o2 = x*[1 1] + m2*[1 -1]/2;
      plot(o1(2,:), o1(1,:), 'r', ...
           o2(2,:), o2(1,:), 'b', ...
           'LineWidth', 1.5);
    end
  end
end
function plot_2T_glyphs(f,param)
  if isempty(f), return, end
  FA = param.FA_min;
  T = param.theta_min;
  for f = f
    x = f(1:2);
    [m1 l1 m2 l2] = state2tensor(f(3:end));
    if l2fa(l1) > FA
      X = x*[1 1] + m1(1:2)*[1 -1]/2;
      plot(X(2,:), X(1,:), 'b', 'LineWidth', 1.5);
    end
    if l2fa(l2) > FA
      X = x*[1 1] + m2(1:2)*[1 -1]/2;
      plot(X(2,:), X(1,:), 'r', 'LineWidth', 1.5);
    end
  end
end
function plot_SH_glyphs(f,param)
  if isempty(f), return, end
  T = param.theta_min;
  for f = f
    x = f(1:2);
    m1 = f(3:5); m2 = f(6:8);
    if abs(m1' * m2) > cos(5*pi/180)   % HACK
      continue
    end

    x1 = x*[1 1] + m1(1:2)*[1 -1]/2;
    x2 = x*[1 1] + m2(1:2)*[1 -1]/2;
    plot(x1(2,:), x1(1,:), 'b', x2(2,:), x2(1,:), 'r', 'LineWidth', 1.5);
  end
end
function plot_3TW_glyphs(f,param)
  if isempty(f), return, end
  FA = param.FA_min; W = param.w_min;
  T = param.theta_min;
  for f = f
    x = f(1:2);
    [m1 l1 w1 m2 l2 w2 m3 l3 w3] = state2tw(f(3:end));
    m1 = m1(1:2); m2 = m2(1:2); m3 = m3(1:2);
    is_A = l2fa(l1) > FA && w1 > param.w_min;
    is_B = l2fa(l2) > FA && w2 > param.w_min;
    is_C = l2fa(l3) > FA && w3 > param.w_min;
    
    foo = {};
    if is_A
      o = x*[1 1] + m1*[1 -1]/2;
      foo = {o(2,:) o(1,:) 'r'};
    end
    if is_B
      o = x*[1 1] + m2*[1 -1]/2;
      foo = {foo{:} o(2,:) o(1,:) 'b'};
    end
    if is_C
      o = x*[1 1] + m3*[1 -1]/2;
      foo = {foo{:} o(2,:) o(1,:) 'g'};
    end
    plot(foo{:}, 'LineWidth', 1.5);
  end
end
