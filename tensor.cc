#include <mex.h>
#include <math.h>

#include "vec3.h"
#include "mat3.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *o = mxGetPr(prhs[0]);
    double *u = mxGetPr(prhs[1]);
    const int *u_dims = mxGetDimensions(prhs[1]);
    double b = mxGetScalar(prhs[2]);

    /* unpack and normalize orientation */
    vec_t m = make_vec(o[0], o[1], o[2]); m /= norm(m);
    double l1 = o[3], l2 = o[4];

    /* flip orientation if necessary */
    if (m._[0] < 0)
        m = -m;

    /* calculate diffusion matrix */
    double x = m._[0], y = m._[1], z = m._[2];
    mat_t R = make_mat(x,  y,                      z,
                       y,  y*y/(1+x)-1,    y*z/(1+x),
                       z,  y*z/(1+x),    z*z/(1+x)-1);
    mat_t D = R * diag(l1,l2,l2) * t(R) * 1e-6;

    /* reconstruct signal */
    int n = u_dims[0];
    mxArray *m_s = plhs[0] = mxCreateDoubleMatrix(n,1,mxREAL);
    double *s = mxGetPr(m_s);
    for (int i = 0; i < n; i++) {
        vec_t u_ = make_vec(u[i], u[n+i], u[2*n+i]);
        s[i] = exp(-b * dot(u_, D * u_));
    }
}
