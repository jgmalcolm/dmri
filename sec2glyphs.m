function sec_ = sec2glyphs(sec)
% convert spawn points to individual line segments
  
  n = 2*sum(cellfun(@(f) size(f,2), sec));
  
  sec_ = cell(1,n);
  i = 1;
  for j = 1:numel(sec)
    f = sec{j};
    for k = 1:size(f,2)
      x = f(1:3,k);
      %[m1 k1 m2 k2] = state2watson(f(4:end,k));
%       [m1 l1 m2 l2] = state2tensor(f(4:end,k));
%       sec_{i  } = x * [1 1] + m1 * [1 -1]/4;
%       sec_{i+1} = x * [1 1] + m2 * [1 -1]/4;
      [m1 l1 w1 m2 l2 w2] = state2tensorW(f(4:end,k));
%       w1 = sum(l1) + l1(2);
%       w2 = sum(l2) + l2(2);
%       fx = w1 + w2;
%       w1 = w1 / fx;
%       w2 = w2 / fx;
      sec_{i  } = x * [1 1] + m1 * [1 -1]/2 * w1;
      sec_{i+1} = x * [1 1] + m2 * [1 -1]/2 * w2;
      i = i + 2;
    end
  end
  sec_ = {sec_{1:i-1}}; % trim
end
