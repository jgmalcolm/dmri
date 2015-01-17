function IDs = read_group(group)
  fid = fopen(['patients_' group '.txt'], 'r');
  IDs = fscanf(fid, '%d', inf)';
  fclose(fid);
end
