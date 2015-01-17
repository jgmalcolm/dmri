#include <math.h>
// 3x1 vector

#ifndef __VEC3_H
#define __VEC3_H

typedef struct { double _[3]; } vec_t;

inline vec_t make_vec(double x, double y, double z)
{
    vec_t m = { {x,y,z} };
    return m;
}
inline vec_t make_vec(double th, double phi)
{
    double cosphi = cos(phi);
    double x = cosphi * cos(th), y = cosphi * sin(th), z = sin(phi);
    return make_vec(x,y,z);
}
inline vec_t make_vec_s(double *sph)
{
    double th = sph[0], phi = sph[1];
    return make_vec(th,phi);
}
inline vec_t make_vec_c(double *m)
{
    return make_vec(m[0],m[1],m[2]);
}
inline void vec2sph(vec_t m, double *sph)
{
    double x = m._[0], y = m._[1], z = m._[2];
    sph[0] = atan2(y, x);
    sph[1] = atan2(z, hypot(x, y));
}
inline void vec2mem(vec_t v, double *m)
{
    for (int i = 0; i < 3; i++)
        m[i] = v._[i];
}


// negation
inline vec_t operator-(vec_t a)
{
    return make_vec(-a._[0], -a._[1], -a._[2]);
}

// addition
inline vec_t operator+(vec_t a, double b)
{
    return make_vec(a._[0]+b, a._[1]+b, a._[2]+b);
}
inline vec_t operator+(double a, vec_t b) { return b + a; }
inline void operator+=(vec_t &a, double b)
{
    a._[0] += b;
    a._[1] += b;
    a._[2] += b;
}

// subtraction
inline vec_t operator-(vec_t a, double b)
{
    return make_vec(a._[0]-b, a._[1]-b, a._[2]-b);
}
inline vec_t operator-(double a, vec_t b)
{
    return make_vec(a-b._[0], a-b._[1], a-b._[2]);
}
inline void operator-=(vec_t &a, double b)
{
    a._[0] -= b;
    a._[1] -= b;
    a._[2] -= b;
}

// multiplication
inline vec_t operator*(vec_t a, double b)
{
    return make_vec(a._[0]*b, a._[1]*b, a._[2]*b);
}
inline vec_t operator*(double a, vec_t b) { return b * a; }
inline void operator*=(vec_t &a, double b)
{
    a._[0] *= b;
    a._[1] *= b;
    a._[2] *= b;
}

// division
inline vec_t operator/(vec_t a, double b)
{
    return make_vec(a._[0]/b, a._[1]/b, a._[2]/b);
}
inline vec_t operator/(double a, vec_t b)
{
    return make_vec(a/b._[0], a/b._[1], a/b._[2]);
}
inline void operator/=(vec_t &a, double b)
{
    a._[0] /= b;
    a._[1] /= b;
    a._[2] /= b;
}


inline double norm(vec_t a)
{
    return sqrt(a._[0]*a._[0] + a._[1]*a._[1] + a._[2]*a._[2]);
}


inline double dot(vec_t a, vec_t b)
{
    return a._[0]*b._[0] + a._[1]*b._[1] + a._[2]*b._[2];
}

#endif
