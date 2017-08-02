
# TRAJECTORY.M

# Generate the overall surface, then overlay the sample points from a
# simulation run.  3D (mesh) or 2D (contour)

graphics_toolkit gnuplot

fig = figure
set(fig, "visible", "off")

show_f

px = load("x.dat");
py = load("y.dat");
pz = load("z.dat");

## try
##   # px = load(sprintf("survivors-x-%i.dat", iteration));
##   px = load("survivors-x.dat");
##   py = load("survivors-y.dat");
## catch
##   printf("warning: empty survivors!\n")
##   px = py = [];
## end

n = size(px)(1)
s = ones(n,1)*8;
c = zeros(n,3);

hold on
## # scatter3(px,py,pz,s,c);
scatter(px,py,s,c);

## px = load("children-x.dat");
## py = load("children-y.dat");

## n = size(px)(1)
## s = ones(n,1)*8;
## c = zeros(n,3);
## c(:,1) = 1 # Red

## # scatter3(px,py,pz,s,c);
## scatter(px,py,s,c);

print "plot.png"
printf "done.\n"
