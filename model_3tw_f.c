#include <mex.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mxArray *m_X = plhs[0] = mxDuplicateArray(prhs[0]);
    double *X = mxGetPr(m_X);
    const int *X_dims = mxGetDimensions(prhs[0]);

    for (int i = 0; i < X_dims[1]; i++) {

        double *m1 = X, *m2 = m1+6, *m3 = m2+6;

        /* normalize M */
        double m1_ = mxGetEps(), m2_ = m1_, m3_ = m1_;
        for (int i = 0; i < 3; i++) {
            m1_ += m1[i]*m1[i];
            m2_ += m2[i]*m2[i];
            m3_ += m3[i]*m3[i];
        }
        m1_ = sqrt(m1_);
        m2_ = sqrt(m2_);
        m3_ = sqrt(m3_);
        for (int i = 0; i < 3; i++) {
            m1[i] /= m1_;
            m2[i] /= m2_;
            m3[i] /= m3_;
        }

        /* prepare for next */
        X += X_dims[0];
    }
}
