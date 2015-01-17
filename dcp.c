#include <mex.h>

inline float dist(float *x, float *y)
{
    float dx = x[0] - y[0];
    float dy = x[1] - y[1];
    float dz = x[2] - y[2];
    return dx*dx + dy*dy + dz*dz;
}

inline float min(float a, float b)
{
    return a < b ? a : b;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const mxArray *m_X = prhs[0], *m_Y = prhs[1];
    if (!mxIsSingle(m_X) || !mxIsSingle(m_Y))
        mexErrMsgTxt("requires single precision input");

    const int *X_dims = mxGetDimensions(m_X);
    const int *Y_dims = mxGetDimensions(m_Y);
    int nx = X_dims[1], ny = Y_dims[1];
    if (X_dims[0] != 3 || nx < 1 || Y_dims[0] != 3 || ny < 1)
        mexErrMsgTxt("requires both as size=[3 n]");

    /* center */
    mxArray *m_D = plhs[0] = mxCreateNumericMatrix(1,nx,mxSINGLE_CLASS,mxREAL);
    float *X = mxGetData(m_X), *Y = mxGetData(m_Y), *D = mxGetData(m_D);

    while (nx--) {
        float d = dist(X,Y);
        for (int i = 1; i < ny; i++) {
            float *y = Y + 3*i;
            d = min(d, dist(X,y));
        }
        *D = d;
        D += 1; X += 3; /* next */
    }
}
