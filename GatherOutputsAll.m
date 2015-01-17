function GatherOutputsAll()
%this functions puts the multiple mat files obtained
%using different runs into a single mat file
where = '/var/tmp/yogesh/';
b1 = 1;
%for my 2T run's
if(b1)
  base = '/home/yogesh/yogesh_pi/phd/lmi-b/2T-fb/';
  %loc = '/home/yogesh/yogesh_pi/phd/lmi/2T-fb/';
  %ndiv = 9;
else
  base = '/home/yogesh/yogesh_pi/phd/lmi/2T-fb/';
  %loc = '/home/yogesh/yogesh_pi/phd/lmi-b/2T-fb/';
  %ndiv = 6;
  %ndiv = 9;
end

 b = sprintf('%s*of*',base);
 d1 = dir(b);
 j = 1;
 ct = 1;
 pats_error = {};
 while j <= numel(d1)
     b2 = sprintf('%s*%s*of*',base,d1(j).name(4:8));
     d2 = dir(b2);
     b3 = sprintf('%s*%s*state*',base,d1(j).name(4:8));
     d3 = dir(b3);
     if ~isempty(d3)
        j = j + numel(d2);
        continue;
     end
     pats{ct} = sprintf('2T-%s',d1(j).name(4:8));
     ndiv(ct) = numel(d2);
     j = j + numel(d2);
     ct = ct + 1;
 end
 
ct = 1;
for i = 1:numel(pats)
  [ff ff2 param] = gather(base,pats{i},ndiv(i)); 
  if(isempty(ff))
    fprintf('%s - files not found \n', pats{i});
    pats_error{ct} = pats{i};
    ct = ct  + 1;
  else
  
  fn1 = [where pats{i} '-state.mat']; %save only the state
  fn2 = [where pats{i} '-cov.mat']; %save the covariance
  disp(fn1)
  save(fn1, 'ff', 'param', '-v7.3');
  
  ff = [];
  ff = ff2; 
  ff2 = [];
  disp(fn2)
  save(fn2, 'ff', 'param', '-v7.3');
  %clear ff;
  ff = [];
  ff2 = [];
 end

end

pats_error

end
