#include <mex.h>
#include <math.h>

#include "vec3.h"
#include "mat3.h"


static mat_t diffusion(vec_t m, double l1, double l2)
{
    double x = m._[0], y = m._[1], z = m._[2];
    mat_t R = make_mat(x,  y,            z          ,
                       y,  y*y/(1+x)-1,  y*z/(1+x)  ,
                       z,  y*z/(1+x),    z*z/(1+x)-1);
    return R * diag(l1,l2,l2) * t(R) * 1e-6;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 3)
        mexErrMsgTxt("requires three inputs");

    double *X = mxGetPr(prhs[0]);
    const int *X_dims = mxGetDimensions(prhs[0]);
    int m = X_dims[1];
    if (X_dims[0] != 18)
        mexErrMsgTxt("X of size [18 n]");

    double *u = mxGetPr(prhs[1]);
    const int *u_dims = mxGetDimensions(prhs[1]);
    int n = u_dims[0];

    mxArray *m_s = plhs[0] = mxCreateDoubleMatrix(n,m,mxREAL);
    double *s = mxGetPr(m_s);

    double b = mxGetScalar(prhs[2]);

    for (int i = 0; i < m; i++) {
        double *o1 = X, *o2 = o1 + 6, *o3 = o2 + 6;

        /* unpack and normalize orientations */
        vec_t m1 = make_vec(o1[0], o1[1], o1[2]); m1 /= norm(m1);
        double l11 = o1[3], l12 = o1[4], w1 = o1[5];
        vec_t m2 = make_vec(o2[0], o2[1], o2[2]); m2 /= norm(m2);
        double l21 = o2[3], l22 = o2[4], w2 = o2[5];
        vec_t m3 = make_vec(o3[0], o3[1], o3[2]); m3 /= norm(m3);
        double l31 = o3[3], l32 = o3[4], w3 = o3[5];

        /* flip if necessary */
        if (m1._[0] < 0)   m1 = -m1;
        if (m2._[0] < 0)   m2 = -m2;
        if (m3._[0] < 0)   m3 = -m3;

        /* calculate diffusion matrix */
        mat_t D1 = diffusion(m1, l11, l12);
        mat_t D2 = diffusion(m2, l21, l22);
        mat_t D3 = diffusion(m3, l31, l32);

        /* reconstruct signal */
        for (int i = 0; i < n; i++) {
            vec_t u_ = make_vec(u[i], u[n+i], u[2*n+i]);
            double s1 = exp(-b*dot(u_,D1*u_));
            double s2 = exp(-b*dot(u_,D2*u_));
            double s3 = exp(-b*dot(u_,D3*u_));
            s[i] = w1*s1 + w2*s2 + w3*s3;
        }

        /* prepare for next */
        X += X_dims[0];
        s += u_dims[0];
    }
}
