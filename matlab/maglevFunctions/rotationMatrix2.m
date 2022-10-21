%{
    Look at rotationMatrix.m for explanation.
    This is the same rotation matrix without YAW/Mz(p) used because of
    the simmetry around z-axis
%}

function Mr2 = rotationMatrix2(ps,t)
    Mr2 = [
          cos(t),  sin(ps)*sin(t), cos(ps)*sin(t), 0;
          0,       cos(ps),        -sin(ps),       0;
          -sin(t), sin(ps)*cos(t), cos(ps)*cos(t), 0;
          0,       0,              0,              1
          ];
end