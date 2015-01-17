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
    if (!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]))
        mexErrMsgTxt("double precision required");


    double *X = mxGetPr(prhs[0]);
    const int *X_dims = mxGetDimensions(prhs[0]);
    int m = X_dims[1];

    double *u = mxGetPr(prhs[1]);
    const int *u_dims = mxGetDimensions(prhs[1]);
    int n = u_dims[0];

    mxArray *m_s = plhs[0] = mxCreateDoubleMatrix(n,m,mxREAL);
    double *s = mxGetPr(m_s);

    double b = mxGetScalar(prhs[2]);

    for (int i = 0; i < m; i++) {
        double *o1 = X, *o2 = X + 4;

        /* unpack orientations */
        vec_t m1 = make_vec(o1[0], o1[1]), m2 = make_vec(o2[0], o2[1]);
        double l11 = o1[2], l12 = o1[3];
        double l21 = o2[2], l22 = o2[3];

        /* ensure: lambda >= L */
        double L = 100;
        if (l11 < L)   l11 = L;
        if (l12 < L)   l12 = L;
        if (l21 < L)   l21 = L;
        if (l22 < L)   l22 = L;

        /* flip if necessary */
        if (m1._[0] < 0)   m1 = -m1;
        if (m2._[0] < 0)   m2 = -m2;

        /* calculate diffusion matrix */
        mat_t D1 = diffusion(m1, l11, l12);
        mat_t D2 = diffusion(m2, l21, l22);

        /* reconstruct signal */
        for (int i = 0; i < n; i++) {
            vec_t u_ = make_vec(u[i], u[n+i], u[2*n+i]);
            s[i] = (exp(-b*dot(u_,D1*u_)) + exp(-b*dot(u_,D2*u_)))/2;
        }

        /* prepare for next */
        X += X_dims[0];
        s += u_dims[0];
    }
}
