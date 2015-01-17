function batch_study
  [r03 r24 r28] = loadsome('study_fibers', 'r03', 'r24', 'r28');

  m = size(r03.nc.mu1,1);
  for i = 1:m
    A = squeeze(r03.nc.mu1(i,:,:))';
    B = squeeze(r03.sz.mu1(i,:,:))';
    [h r03.sig1(:,i)] = ttest2(A,B);


    A = squeeze(r03.nc.mu2(i,:,:))';
    B = squeeze(r03.sz.mu2(i,:,:))';
    [h r03.sig2(:,i)] = ttest2(A,B);
  end

  for i = 1:m
    A = squeeze(r24.nc.mu1(i,:,:))';
    B = squeeze(r24.sz.mu1(i,:,:))';
    [h r24.sig1(:,i)] = ttest2(A,B);


    A = squeeze(r24.nc.mu2(i,:,:))';
    B = squeeze(r24.sz.mu2(i,:,:))';
    [h r24.sig2(:,i)] = ttest2(A,B);
  end

  for i = 1:m
    A = squeeze(r28.nc.mu1(i,:,:))';
    B = squeeze(r28.sz.mu1(i,:,:))';
    [h r28.sig1(:,i)] = ttest2(A,B);


    A = squeeze(r28.nc.mu2(i,:,:))';
    B = squeeze(r28.sz.mu2(i,:,:))';
    [h r28.sig2(:,i)] = ttest2(A,B);
  end

  save('study_stats', 'r03', 'r24', 'r28');
end
