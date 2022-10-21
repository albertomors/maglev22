%{
    https://www.brainvoyager.com/bv/doc/UsersGuide/CoordsAndTransforms/SpatialTransformationMatrices.html
    
    4x4 matrix where:
        top-left 3x3 sub-matrix represents an orientation matrix (I_3x3 => no rotation),
        top-left 1x3 sub-matrix represents a translation matrix
        last row 4x1 is always [0 0 0 1]
%}

function Mt = translationMatrix(x,y,z)
    Mt = [
            1,  0,  0,  x;
            0,  1,  0,  y;
            0,  0,  1,  z;
            0,  0,  0,  1
         ];
end
