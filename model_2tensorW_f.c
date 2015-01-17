#include <mex.h>
#include <math.h>

inline double dot(double *x, double *y)
{
    return x[0]*y[0] + x[1]*y[1] + x[2]*y[2];
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mxArray *m_X = plhs[0] = mxDuplicateArray(prhs[0]);
    double *X = mxGetPr(m_X);
    const int *X_dims = mxGetDimensions(prhs[0]);
    if (X_dims[0] != 11)
        mexErrMsgTxt("X of size [11 n]");

    for (int i = 0; i < X_dims[1]; i++) {

        double *m1 = X, *m2 = X+6;

        /* only normalize M */
        double m1_ = mxGetEps(), m2_ = m1_;
        for (int i = 0; i < 3; i++) {
            m1_ += m1[i]*m1[i];
            m2_ += m2[i]*m2[i];
        }
        m1_ = sqrt(m1_);
        m2_ = sqrt(m2_);
        for (int i = 0; i < 3; i++) {
            m1[i] /= m1_;
            m2[i] /= m2_;
        }

        /* prepare for next */
        X += X_dims[0];
    }
}
