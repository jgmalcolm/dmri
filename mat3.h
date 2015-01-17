// 3x3 matrix

#ifndef __MAT3_H
#define __MAT3_H

#include "vec3.h"

typedef struct { double _[9]; } mat_t;

inline mat_t make_mat(double a, double b, double c,
                      double d, double e, double f,
                      double g, double h, double i)
{
    mat_t m = { {a,b,c, d,e,f, g,h,i} };
    return m;
}
inline mat_t diag(double a, double b, double c)
{
    mat_t m = { {a,0,0, 0,b,0, 0,0,c} };
    return m;
}
inline mat_t t(mat_t m)
{
    return make_mat(m._[0], m._[3], m._[6],
                    m._[1], m._[4], m._[7],
                    m._[2], m._[5], m._[8]);
}

// matrix-scalar
inline mat_t operator*(mat_t a, double b)
{
    return make_mat(a._[0]*b,  a._[1]*b, a._[2]*b,
                    a._[3]*b,  a._[4]*b, a._[5]*b,
                    a._[6]*b,  a._[7]*b, a._[8]*b);
}
inline mat_t operator*(double a, mat_t b)
{
    return b * a;
}

// matrix-vector
inline vec_t operator*(mat_t a, vec_t b)
{
    return make_vec(a._[0]*b._[0] + a._[1]*b._[1] + a._[2]*b._[2],
                    a._[3]*b._[0] + a._[4]*b._[1] + a._[5]*b._[2],
                    a._[6]*b._[0] + a._[7]*b._[1] + a._[8]*b._[2]);
}


// matrix-matrix
inline mat_t operator*(mat_t a, mat_t b)
{
    return make_mat(a._[0]*b._[0] + a._[1]*b._[3] + a._[2]*b._[6],
                    a._[0]*b._[1] + a._[1]*b._[4] + a._[2]*b._[7],
                    a._[0]*b._[2] + a._[1]*b._[5] + a._[2]*b._[8],

                    a._[3]*b._[0] + a._[4]*b._[3] + a._[5]*b._[6],
                    a._[3]*b._[1] + a._[4]*b._[4] + a._[5]*b._[7],
                    a._[3]*b._[2] + a._[4]*b._[5] + a._[5]*b._[8],

                    a._[6]*b._[0] + a._[7]*b._[3] + a._[8]*b._[6],
                    a._[6]*b._[1] + a._[7]*b._[4] + a._[8]*b._[7],
                    a._[6]*b._[2] + a._[7]*b._[5] + a._[8]*b._[8]);
}

// determinant
inline double det(mat_t M)
{
    return M._[0]*(M._[4]*M._[8] - M._[5]*M._[7])
        -  M._[1]*(M._[3]*M._[8] - M._[5]*M._[6])
        +  M._[2]*(M._[3]*M._[7] - M._[4]*M._[6]);
}

// conjugate transpose
inline mat_t ct(mat_t M)
{
    return make_mat( M._[0], -M._[3],  M._[6],
                    -M._[1],  M._[4], -M._[7],
                     M._[2], -M._[5],  M._[8]);
}

// invert
inline mat_t inv(mat_t M)
{
    return (1 / det(M)) * ct(M);
}

#endif
