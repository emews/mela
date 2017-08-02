
# F.M
# Octave form of f() for visualization
# Translated to Tcl in Tcl/Tcl-Task/task.tcl

function v = f(x,y)
  v1 = sin(4*x);
  v2 = sin(4*y);
  v3 = -2*x+2*x^2;
  v4 = -2*y+2*y^2;
  v = v1 + v2 + v3 + v4;
  % printf("%0.2f %0.2f -> %0.2f\n", x, y, v);
end
