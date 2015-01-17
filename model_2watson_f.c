#include <mex.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const int *X_dims = mxGetDimensions(prhs[0]);
    if (X_dims[0] == 1 && X_dims[1] > 1)
        mexErrMsgTxt("expects column vectors");

    mxArray *m_X = plhs[0] = mxDuplicateArray(prhs[0]);
    double *X = mxGetPr(m_X);

    for (int i = 0; i < X_dims[1]; i++) {
        double *m1 = X,   *k1 = m1 + 3;
        double *m2 = X+4, *k2 = m2 + 3;
    
        /* clamp K */
        if (*k1 < .01)   *k1 = .01;
        if (*k2 < .01)   *k2 = .01;

        /* normalize M */
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
