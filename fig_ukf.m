disp = false;

u = icosahedron(2);
s_clean = gen_2cross_w(u, 0, .5, 0.0, 1, 1000);
s_clean = flat(s_clean(1,10,:));
s_dirty = gen_2cross_w(u, 0, .5, 0.2, 1, 1000);
s_dirty = flat(s_dirty(1,10,:));

pos = [0 0 1 1] + .05*[-1 -1 2 2];

clf;

if disp, sp(5,1,1); end
odf(s_dirty, u); axis image off; view(-30,-40);
if ~disp
  set(gca, 'Position', pos);
  print('-dpng', '-r70', 'figs/ukf_0');
end


vv = -[[30 40]' [30 10]' [30 70]' [10 40]' [50 40]'];
for i = 1:5
  if disp, sp(5,1,1+i); else clf; end
  odf(s_clean, u); axis image off;
  view(vv(1,i), vv(2,i));
  if ~disp
    set(gca, 'Position', pos); 
    print('-dpng', '-r70', ['figs/ukf_' int2str(i)]);
  end
end
