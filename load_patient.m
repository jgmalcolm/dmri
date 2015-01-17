function [S u b m wm gm] = load_patient(id)

  base = sprintf('/projects/schiz/3Tdata/case%05d', id);
  
  S = sprintf('%s/diff/%05d-dwi-filt-Ed.nhdr', base, id);
  m = sprintf('%s/diff/Tensor_mask-%05d-dwi-filt-Ed_AvGradient-edited.raw.gz', base, id);
  wm = sprintf(['%s/projects/20071213-usman-coreg/1_transform_tst/' ...
                'xformed_case%05d_ICBM_WMPM.raw.gz'], base, id);
  gm = sprintf(['%s/projects/20090604-sylvain-strct2dti/' ...
                '%05d--wmparc2bse.nrrd'], base, id);

  [S u b] = nhdr_diff(S);
  if nargout >= 4,  m  = nhdr2mat(m,  'int16', [144 144 85]) ~= 0; end
  if nargout >= 5,  wm = nhdr2mat(wm, 'uint8', [144 144 85]); end
  if nargout >= 6,  gm = nrrdZipLoad(gm); end

end
