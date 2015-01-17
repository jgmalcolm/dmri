#include <mex.h>
#include <math.h>

template<class ty>
void triu_nz(void *_out, void *_in, int n)
{
    ty *out = (ty *)_out, *in = (ty *)_in;

    int i = 0;
    for (int col = 0; col < n; col++)
        for (int row = 0; row < col+1; row++)
            out[i++] = in[col*n + row];
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 1) mexErrMsgTxt("requires one input");
    if (nlhs > 1)  mexErrMsgTxt("produces one output");

    const mxArray *m_A = prhs[0];
    int numel = mxGetNumberOfElements(m_A);
    int n = sqrt(numel);
    if (n*n != numel) mexErrMsgTxt("requires square input");

    mxClassID cls = mxUNKNOWN_CLASS;
    if (mxIsSingle(m_A))       cls = mxSINGLE_CLASS;
    else if (mxIsDouble(m_A))  cls = mxDOUBLE_CLASS;
    else  mexErrMsgTxt("requires single or double precision");

    mxArray *m_B = plhs[0] = mxCreateNumericMatrix(n*(n+1)/2, 1, cls, mxREAL);

    void *a = mxGetData(m_A), *b = mxGetData(m_B);

    if (mxIsSingle(m_A))   triu_nz<float>(b, a, n);
    else                   triu_nz<double>(b, a, n);
}
