% f
function [f, f1, f2, f3] = VMMix_f(x, mu, k, p1, p2, p3)
g = VMMix_g(x, mu, k);
g_pi = VMMix_g(x, mu + pi, k);
const = 1/2/pi;
z = sum(exp([p1, p2, p3]));
f1 = exp(p1)*g/z;
f2 = exp(p2)*g_pi/z;
f3 = exp(p3)*const/z;
f = f1 + f2 + f3;
end