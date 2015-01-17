#include <mex.h>
#include <math.h>

#define SIGMA  .5

template<class ty>
double _fetch(void *_D, mwSize ind)
{
    ty *D = (ty *)_D;
    return D[ind];
}
static double fetch(const mxArray *m_D, mwSize ind)
{
    mxClassID cls = mxGetClassID(m_D);
    void *D = mxGetData(m_D);
    if (cls == mxLOGICAL_CLASS)
        D = (void *)mxGetLogicals(m_D);
    switch (cls) {
    case mxLOGICAL_CLASS: return _fetch<mxLogical>(D,ind);
    case mxSINGLE_CLASS:  return _fetch<float>(    D,ind);
    case mxDOUBLE_CLASS:  return _fetch<double>(   D,ind);
    default: mexErrMsgTxt("unsupported type"); return 0;
    }
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsDouble(prhs[1]))
        mexErrMsgTxt("interp3scalar: double precision position required");
    if (nrhs == 3 && !mxIsDouble(prhs[2]))
        mexErrMsgTxt("interp3scalar: double precision voxel size required");

    const mxArray *D = prhs[0];
    double *p = mxGetPr(prhs[1]);
    double *v = nrhs == 3 ? mxGetPr(prhs[2]) : NULL;

    const int *dims = mxGetDimensions(prhs[0]);
    int nx = dims[0], ny = dims[1], nz = dims[2];

    double val = 0, w_sum = mxGetEps();
    for (int zz = -1; zz <= 1; zz++) {
        for (int yy = -1; yy <= 1; yy++) {
            for (int xx = -1; xx <= 1; xx++) {
                int x = (int)round(p[0]-1) + xx;
                int y = (int)round(p[1]-1) + yy;
                int z = (int)round(p[2]-1) + zz;
                if (x < 0 || nx <= x) continue;
                if (y < 0 || ny <= y) continue;
                if (z < 0 || nz <= z) continue;
                double dx = x-p[0]+1, dy = y-p[1]+1, dz = z-p[2]+1;
                if (v) {
                    dx *= v[0]; dy *= v[1]; dz *= v[2]; /* scale voxel */
                }
                double w = exp( -(dx*dx + dy*dy + dz*dz)/(SIGMA) );
                double d = fetch(D, nx*ny*z + nx*y + x);
                val   += w * d;
                w_sum += w;
            }
        }
    }
    
    plhs[0] = mxCreateDoubleScalar(val / w_sum);
}
