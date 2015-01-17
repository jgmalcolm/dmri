function batch_arc

[S b u] = loadsome('lmi/tmi/arc', 'S', 'b', 'u');
ff_2t = loadsome('lmi/tmi/arc_2T','ff');
ff_dt = fibers_dt(ff_2t, S, u, b);

ff_2t_top = empty(map(@(X) X(:, X(1,:) < 6  & X(2,:) < 8 ), ff_2t));
ff_2t_bot = empty(map(@(X) X(:, X(1,:) > 10 & X(2,:) < 8 ), ff_2t));
ff_2t_arc = empty(map(@(X) X(:,               X(2,:) > 8 ), ff_2t));

ff_dt_top = empty(map(@(X) X(:, X(1,:) < 6  & X(2,:) < 8 ), ff_dt));
ff_dt_bot = empty(map(@(X) X(:, X(1,:) > 10 & X(2,:) < 8 ), ff_dt));
ff_dt_arc = empty(map(@(X) X(:,               X(2,:) > 8 ), ff_dt));

% ff_dt_top = map(@flat, ff_dt_top);
% ff_dt_bot = map(@flat, ff_dt_bot);
% ff_dt_arc = map(@arc,  ff_dt_arc);

[top_pri top_sec] = map(@arc_err, ff_2t_top, ff_dt_top);
[bot_pri bot_sec] = map(@arc_err, ff_2t_bot, ff_dt_bot);
[arc_pri arc_sec] = map(@arc_err, ff_2t_arc, ff_dt_arc);

top_pri = [top_pri{:}];   top_sec = [top_sec{:}];
bot_pri = [bot_pri{:}];   bot_sec = [bot_sec{:}];
arc_pri = [arc_pri{:}];   arc_sec = [arc_sec{:}];

display('primary');
fprintf('top:   %f  +/-  %f\n', mean(top_pri), std(top_pri));
fprintf('bot:   %f  +/-  %f\n', mean(bot_pri), std(bot_pri));
fprintf('       %f  +/-  %f\n', mean([top_pri bot_pri]), std([top_pri bot_pri]));
fprintf('arc:   %f  +/-  %f\n', mean(arc_pri), std(arc_pri));

display('secondary');
fprintf('top:   %f  +/-  %f\n', mean(top_sec), std(top_sec));
fprintf('bot:   %f  +/-  %f\n', mean(bot_sec), std(bot_sec));
fprintf('       %f  +/-  %f\n', mean([top_sec bot_sec]), std([top_sec bot_sec]));
fprintf('arc:   %f  +/-  %f\n', mean(arc_sec), std(arc_sec));

show_glyphs(signal2ga(S), ff_2t); 
axis off;

hold on
box = [.5 1 1 .5 .5; 0 0 4 4 0] + .8;                               
plot(box(1,:), box(2,:), 'g', 'LineWidth', 7,'Color', [0 .7 0]);
hold off

print('-dpng', '-r70', 'lmi/tmi/loop');

end

function x = flat(x)
  x([3 5],:) = 0;
  x(4,:) = 1;
end
function x = arc(x)
end
  


function [mu sd] = stats(e)
  mu = cellfun(@mean, e);
  sd = cellfun(@std,  e);
end

% X == filtered two-tensor
% Y == single-tensor
function [e1 e2] = arc_err(X,Y)
  n = size(X,2);
  assert(n == size(Y,2));
  assert(size(X,1) == 12);
  assert(size(Y,1) == 7);
  
  x1 = X(3:5,:);
  x2 = X(8:10,:);
  y  = Y(3:5,:);
  
  % normalize
  x1 = bsxfun(@rdivide, x1, sqrt(sum(x1.^2)) + eps);
  x2 = bsxfun(@rdivide, x2, sqrt(sum(x2.^2)) + eps);

  e1 = acosd(abs(sum(x1.*y)));
  e2 = acosd(abs(sum(x2.*y)));
  
  flip = find(e2 < e1);
  [e1(flip) e2(flip)] = deal(e2(flip), e1(flip));
end
