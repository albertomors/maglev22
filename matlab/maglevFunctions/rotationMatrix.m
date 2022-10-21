%{
    https://en.wikipedia.org/wiki/Rotation_matrix
    
    Mr =  Mz(p) * My(ps) * Mx(t) = YAW * PITCH * ROLL where:
        
          Mz(p) = [ 1, 0,      0;
                    0, cos(p), -sin(p);
                    0, sin(p), cos(p);
                  ];

          My(ps) = [ cos(ps), -sin(ps), 0;
                     sin(ps), cos(ps),  0;
                     0        0         1
                   ];

        Mx(t) = [ cos(t),  0, sin(t);
                  0,       1, 0;
                  -sin(t), 0, cos(t)
                ];    
    
    4x4 matrix where:
        top-left 3x3 sub-matrix is Mr
        top-left 1x3 sub-matrix represents a translation matrix (0_1x3 => no translation),
        last row 4x1 is always [0 0 0 1]
%}

function Mr = rotationMatrix(ps,t,p)
    Mr = [
            cos(t)*cos(p), sin(ps)*sin(t)*cos(p) - cos(ps)*sin(p), cos(ps)*sin(t)*cos(p) + sin(ps)*sin(p), 0;
            cos(t)*sin(p), sin(ps)*sin(t)*sin(p) + cos(ps)*cos(p), cos(ps)*sin(t)*sin(p) - sin(ps)*cos(p), 0;
            -sin(t),       sin(ps)*cos(t),                         cos(ps)*cos(t),                         0;
            0,             0,                                      0,                                      1
         ];
end