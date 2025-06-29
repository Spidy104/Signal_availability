x = [3, 11, 7, 0, -1, 4, 2];
nx = -3:3;
e1 = signal_plotting(x, nx);
[y, ny] = e1.sigshift(2);
w = randn(1, length(y));
nw = ny;
e2 = signal_plotting(y, ny);
[x1, nx1] = e2.sigadd(w, nw);
[x, nx] = e1.sigfold();
[rxy, nxy] = conv_m(x1, nx1, x, nx);
stem(nxy, rxy);
axis([-5, 10, -50, 250])