function fig_post_angle(f1, f2, th)
  for th = th
    F2 = f2(cellfun(@(f) is_acute(f, cos(th* pi/180)), f2));
    fn = sprintf('/tmp/tensor_MRI_%02d', th)
    ff = {f1{:} F2{:}};
    xx = map(@(x)single(x(1:3,:)), empty(ff));
    numel(xx)
    ijk2vtk(xx, fn);
  end
end

function b = is_acute(f, th)
  [m1 l1 m2 l2] = state2tensor(f(4:13));
  b = m1' * m2 > th;
end
