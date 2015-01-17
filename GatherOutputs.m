function GatherOutputs()
%this functions puts the multiple mat files obtained
%using different runs into a single mat file
% % base = '/home/malcolm/src/lmi/fb/';
% % 
% % pats = {'2T-01026', '2T-01035', '2T-01046', '2T-01047', '2T-01054','2T-01057', ...
% %         '2T-01061', '2T-01065', '2T-01084', '2T-01093', '2T-01094','2T-01099', ...
% %         '2T-01107', '2T-01110', '2T-01115', '2T-01118', '2T-01126', ...
% %         '2T-01137', '2T-01145', '2T-01146', '2T-01149', '2T-01154', '2T-01157', ...
% %         '2T-01158', '2T-01162', '2T-01163', '2T-01165', '2T-01166', '2T-01171', ...
% %         '2T-01174', '2T-01175', '2T-01176'};
% % for i = 1:numel(pats)
 %   [ff param] = gather([base 'fb2T/'],pats{i},2);
% %   fn = [base pats{i} '.mat'];
% %   disp(fn)
% %   save(fn, 'ff', 'param', '-v7.3');
% % 
% % end

addpath ~malcolm/src;
addpath ~malcolm/lib;

b1 = 1;
%for my 2T run's
if(b1)
  base = '/home/yogesh/yogesh_pi/phd/lmi-b/2T-fb/';
  ndiv = 9;
else
  base = '/home/yogesh/yogesh_pi/phd/lmi/2T-fb/';
  ndiv = 6;
  %ndiv = 9;
end

where = '/var/tmp/yogesh/';
%problem reading 2T-01047 01062

pats = {'2T-01178', '2T-01183'};
%pats = {'2T-01010'};
%pats = {'2T-01063', '2T-01065','2T-01066', '2T-01067'};
%pats = {'2T-01039','2T-01038', '2T-01040', '2T-01041', '2T-01042', '2T-01043', '2T-01044', '2T-01045','2T-01047','2T-01053','2T-01054','2T-01057'}%

%pats = {'2T-01024','2T-01025','2T-01026','2T-01027','2T-01028','2T-01029', '2T-01030', '2T-01031', '2T-01032', '2T-01033','2T-01034','2T-01035'};
%pats = {'2T-01009', '2T-01010', '2T-01011','2T-01014', '2T-01015', '2T-01017','2T-01018','2T-01019','2T-01020', '2T-01022'};
for i = 1:numel(pats)
  [ff ff2 param] = gather(where,pats{i},ndiv); 
  if(isempty(ff))
    fprintf('%s - files not found \n', pats{i});
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


end
