
# SHOW_F.M

# Generate a 3D mesh or contour from f (f.m)

# Domain is x=[-b,b], y=[-b,b]
b = 2
# Number of grid points in each direction from the origin
n = 10
# Domain D
D = zeros(n,n);
X = zeros(n);
Y = zeros(n);
# Domain discretization
dd = b/n

X = Y = linspace(-b, b, n*2+1);
for i=-n:n
  x = dd*i;
  for j=-n:n
      y = dd*j;
      D(i+n+1,j+n+1) = f(x,y);
  end
end

# m = mesh(X, Y, D);
m = contour(X, Y, D);

xlabel("x")
ylabel("y")
zlabel("z")
