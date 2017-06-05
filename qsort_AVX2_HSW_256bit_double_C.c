#include <immintrin.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>

__attribute__((aligned(64))) int PTL[16*8] = {
0,0,0,0,0,0,0,0,
0,1,0,0,0,0,0,0,
2,3,0,0,0,0,0,0,
0,1,2,3,0,0,0,0,
4,5,0,0,0,0,0,0,
0,1,4,5,0,0,0,0,
2,3,4,5,0,0,0,0,
0,1,2,3,4,5,0,0,
6,7,0,0,0,0,0,0,
0,1,6,7,0,0,0,0,
2,3,6,7,0,0,0,0,
0,1,2,3,6,7,0,0,
4,5,6,7,0,0,0,0,
0,1,4,5,6,7,0,0,
2,3,4,5,6,7,0,0,
0,1,2,3,4,5,6,7
};
__attribute__((aligned(64))) int PTR[16*8] = {
0,1,2,3,4,5,6,7,
2,3,4,5,6,7,0,0,
0,1,4,5,6,7,0,0,
4,5,6,7,0,0,0,0,
0,1,2,3,6,7,0,0,
2,3,6,7,0,0,0,0,
0,1,6,7,0,0,0,0,
6,7,0,0,0,0,0,0,
0,1,2,3,4,5,0,0,
2,3,4,5,0,0,0,0,
0,1,4,5,0,0,0,0,
4,5,0,0,0,0,0,0,
0,1,2,3,0,0,0,0,
2,3,0,0,0,0,0,0,
0,1,0,0,0,0,0,0,
0,0,0,0,0,0,0,0
};

#define swap(a, b, t)\
    t = a;\
    a = b;\
    b = t; 

static void sorts(double *d, unsigned long  n)
{    
    if(n<=1) return;
        long i, j;
        for (i = 1; i < n; i++) {
                double tmp = d[i];
                for (j = i; j >= 1 && tmp < d[j-1]; j--)
                        d[j] = d[j-1];
                d[j] = tmp;
        }
}


int qsort_AVX2(double* in, double *tmp, unsigned long n)
{
    __m256d A0, A1, A2, A3, A4, A5, A6;
    __m256d M0, M1, M2, M3, M4, M5, M6;
    __m256d T;
    __m256d PIVOT;
    double pivot;
    
    double *bottom = in;
    double *top = tmp;
    
    unsigned long m0, m1, m2, m3, m4, m5, m6;
    unsigned long ret_val;
    
    __m256i *PermTableLeft = (__m256i*)PTL;
    __m256i *PermTableRight = (__m256i*)PTR;
	
    if(0)
    {
    double el[5];

    el[0] = in[0];
    el[1] = in[n/2];
    el[2] = in[n-1];
    el[3] = in[n/4];
    el[4] = in[n/2+n/4];

    sorts(el, 5);
    pivot = el[2];
    }
    else{
    //double el1, el2, el3;
    //el1 = in[0];
    //el2 = in[n/2];
    //el3 = in[n-1];
    //
    #define el1 in[0]
    #define el2 in[n-1]
    #define el3 in[n/2]

    if (el1 > el2)
    {
       swap(el1, el2, pivot);
    }
    if (el2 > el3) 
    {
        swap(el2, el3, pivot);
        if (el1 > el2) 
        {
            swap(el1, el2, pivot);
        }
    }

    pivot = el2;
    }

    //if(in[n-1] < in[0]) swap(in[0], in[n-1], pivot);
    //if(in[n/2] < in[0]) swap(in[0], in[n/2], pivot);
    //if(in[n-1] < in[n/2]) swap(in[n-1], in[n/2], pivot);
    //pivot = in[0];
    //


    PIVOT = _mm256_broadcast_sd(&pivot);
    //n--;
    
    while(n>=28)
    //while(0)
    {
        A0 = _mm256_loadu_pd(in + 0*4);
        A1 = _mm256_loadu_pd(in + 1*4);
        A2 = _mm256_loadu_pd(in + 2*4);
        A3 = _mm256_loadu_pd(in + 3*4);
        A4 = _mm256_loadu_pd(in + 4*4);
        A5 = _mm256_loadu_pd(in + 5*4);
        A6 = _mm256_loadu_pd(in + 6*4);
        
        M0 = _mm256_cmp_pd(A0, PIVOT, 2);
        M1 = _mm256_cmp_pd(A1, PIVOT, 2);
        M2 = _mm256_cmp_pd(A2, PIVOT, 2);
        M3 = _mm256_cmp_pd(A3, PIVOT, 2);
        M4 = _mm256_cmp_pd(A4, PIVOT, 2);
        M5 = _mm256_cmp_pd(A5, PIVOT, 2);
        M6 = _mm256_cmp_pd(A6, PIVOT, 2);
        
        m0 = _mm256_movemask_pd(M0);
        m1 = _mm256_movemask_pd(M1);
        m2 = _mm256_movemask_pd(M2);
        m3 = _mm256_movemask_pd(M3);
        m4 = _mm256_movemask_pd(M4);
        m5 = _mm256_movemask_pd(M5);
        m6 = _mm256_movemask_pd(M6);
        
        M0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableLeft[m0]);
        M1 = (__m256d)_mm256_permutevar8x32_ps((__m256)A1, PermTableLeft[m1]);
        M2 = (__m256d)_mm256_permutevar8x32_ps((__m256)A2, PermTableLeft[m2]);
        M3 = (__m256d)_mm256_permutevar8x32_ps((__m256)A3, PermTableLeft[m3]);
        M4 = (__m256d)_mm256_permutevar8x32_ps((__m256)A4, PermTableLeft[m4]);
        M5 = (__m256d)_mm256_permutevar8x32_ps((__m256)A5, PermTableLeft[m5]);
        M6 = (__m256d)_mm256_permutevar8x32_ps((__m256)A6, PermTableLeft[m6]);
        
        A0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableRight[m0]);
        A1 = (__m256d)_mm256_permutevar8x32_ps((__m256)A1, PermTableRight[m1]);
        A2 = (__m256d)_mm256_permutevar8x32_ps((__m256)A2, PermTableRight[m2]);
        A3 = (__m256d)_mm256_permutevar8x32_ps((__m256)A3, PermTableRight[m3]);
        A4 = (__m256d)_mm256_permutevar8x32_ps((__m256)A4, PermTableRight[m4]);
        A5 = (__m256d)_mm256_permutevar8x32_ps((__m256)A5, PermTableRight[m5]);
        A6 = (__m256d)_mm256_permutevar8x32_ps((__m256)A6, PermTableRight[m6]);
        
        m0 = __builtin_popcount(m0);
        m1 = __builtin_popcount(m1);
        m2 = __builtin_popcount(m2);
        m3 = __builtin_popcount(m3);
        m4 = __builtin_popcount(m4);
        m5 = __builtin_popcount(m5);
        m6 = __builtin_popcount(m6);
        
        _mm256_storeu_pd(bottom, M0);
        bottom+=m0;
        _mm256_storeu_pd(bottom, M1);
        bottom+=m1;
        _mm256_storeu_pd(bottom, M2);
        bottom+=m2;
        _mm256_storeu_pd(bottom, M3);
        bottom+=m3;
        _mm256_storeu_pd(bottom, M4);
        bottom+=m4;
        _mm256_storeu_pd(bottom, M5);
        bottom+=m5;
        _mm256_storeu_pd(bottom, M6);
        bottom+=m6;
        
        m0 = 4-m0;
        m1 = 4-m1;
        m2 = 4-m2;
        m3 = 4-m3;
        m4 = 4-m4;
        m5 = 4-m5;
        m6 = 4-m6;
        _mm256_storeu_pd(top, A0);
        top+=m0;
        _mm256_storeu_pd(top, A1);
        top+=m1;
        _mm256_storeu_pd(top, A2);
        top+=m2;
        _mm256_storeu_pd(top, A3);
        top+=m3;
        _mm256_storeu_pd(top, A4);
        top+=m4;
        _mm256_storeu_pd(top, A5);
        top+=m5;
        _mm256_storeu_pd(top, A6);
        top+=m6;
        
        n-=28;
        in+=7*4;
    }
    
    while(n>=24)
    {
        A0 = _mm256_loadu_pd(in + 0*4);
        A1 = _mm256_loadu_pd(in + 1*4);
        A2 = _mm256_loadu_pd(in + 2*4);
        A3 = _mm256_loadu_pd(in + 3*4);
        A4 = _mm256_loadu_pd(in + 4*4);
        A5 = _mm256_loadu_pd(in + 5*4);
        
        M0 = _mm256_cmp_pd(A0, PIVOT, 2);
        M1 = _mm256_cmp_pd(A1, PIVOT, 2);
        M2 = _mm256_cmp_pd(A2, PIVOT, 2);
        M3 = _mm256_cmp_pd(A3, PIVOT, 2);
        M4 = _mm256_cmp_pd(A4, PIVOT, 2);
        M5 = _mm256_cmp_pd(A5, PIVOT, 2);
        
        m0 = _mm256_movemask_pd(M0);
        m1 = _mm256_movemask_pd(M1);
        m2 = _mm256_movemask_pd(M2);
        m3 = _mm256_movemask_pd(M3);
        m4 = _mm256_movemask_pd(M4);
        m5 = _mm256_movemask_pd(M5);
        
        M0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableLeft[m0]);
        M1 = (__m256d)_mm256_permutevar8x32_ps((__m256)A1, PermTableLeft[m1]);
        M2 = (__m256d)_mm256_permutevar8x32_ps((__m256)A2, PermTableLeft[m2]);
        M3 = (__m256d)_mm256_permutevar8x32_ps((__m256)A3, PermTableLeft[m3]);
        M4 = (__m256d)_mm256_permutevar8x32_ps((__m256)A4, PermTableLeft[m4]);
        M5 = (__m256d)_mm256_permutevar8x32_ps((__m256)A5, PermTableLeft[m5]);
        
        A0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableRight[m0]);
        A1 = (__m256d)_mm256_permutevar8x32_ps((__m256)A1, PermTableRight[m1]);
        A2 = (__m256d)_mm256_permutevar8x32_ps((__m256)A2, PermTableRight[m2]);
        A3 = (__m256d)_mm256_permutevar8x32_ps((__m256)A3, PermTableRight[m3]);
        A4 = (__m256d)_mm256_permutevar8x32_ps((__m256)A4, PermTableRight[m4]);
        A5 = (__m256d)_mm256_permutevar8x32_ps((__m256)A5, PermTableRight[m5]);
        
        m0 = __builtin_popcount(m0);
        m1 = __builtin_popcount(m1);
        m2 = __builtin_popcount(m2);
        m3 = __builtin_popcount(m3);
        m4 = __builtin_popcount(m4);
        m5 = __builtin_popcount(m5);
        
        _mm256_storeu_pd(bottom, M0);
        bottom+=m0;
        _mm256_storeu_pd(bottom, M1);
        bottom+=m1;
        _mm256_storeu_pd(bottom, M2);
        bottom+=m2;
        _mm256_storeu_pd(bottom, M3);
        bottom+=m3;
        _mm256_storeu_pd(bottom, M4);
        bottom+=m4;
        _mm256_storeu_pd(bottom, M5);
        bottom+=m5;
        
        m0 = 4-m0;
        m1 = 4-m1;
        m2 = 4-m2;
        m3 = 4-m3;
        m4 = 4-m4;
        m5 = 4-m5;
        _mm256_storeu_pd(top, A0);
        top+=m0;
        _mm256_storeu_pd(top, A1);
        top+=m1;
        _mm256_storeu_pd(top, A2);
        top+=m2;
        _mm256_storeu_pd(top, A3);
        top+=m3;
        _mm256_storeu_pd(top, A4);
        top+=m4;
        _mm256_storeu_pd(top, A5);
        top+=m5;
        
        n-=24;
        in+=6*4;
    }
    
    while(n>=20)
    {
        A0 = _mm256_loadu_pd(in + 0*4);
        A1 = _mm256_loadu_pd(in + 1*4);
        A2 = _mm256_loadu_pd(in + 2*4);
        A3 = _mm256_loadu_pd(in + 3*4);
        A4 = _mm256_loadu_pd(in + 4*4);        
        M0 = _mm256_cmp_pd(A0, PIVOT, 2);
        M1 = _mm256_cmp_pd(A1, PIVOT, 2);
        M2 = _mm256_cmp_pd(A2, PIVOT, 2);
        M3 = _mm256_cmp_pd(A3, PIVOT, 2);
        M4 = _mm256_cmp_pd(A4, PIVOT, 2);        
        m0 = _mm256_movemask_pd(M0);
        m1 = _mm256_movemask_pd(M1);
        m2 = _mm256_movemask_pd(M2);
        m3 = _mm256_movemask_pd(M3);
        m4 = _mm256_movemask_pd(M4);        
        M0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableLeft[m0]);
        M1 = (__m256d)_mm256_permutevar8x32_ps((__m256)A1, PermTableLeft[m1]);
        M2 = (__m256d)_mm256_permutevar8x32_ps((__m256)A2, PermTableLeft[m2]);
        M3 = (__m256d)_mm256_permutevar8x32_ps((__m256)A3, PermTableLeft[m3]);
        M4 = (__m256d)_mm256_permutevar8x32_ps((__m256)A4, PermTableLeft[m4]);        
        A0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableRight[m0]);
        A1 = (__m256d)_mm256_permutevar8x32_ps((__m256)A1, PermTableRight[m1]);
        A2 = (__m256d)_mm256_permutevar8x32_ps((__m256)A2, PermTableRight[m2]);
        A3 = (__m256d)_mm256_permutevar8x32_ps((__m256)A3, PermTableRight[m3]);
        A4 = (__m256d)_mm256_permutevar8x32_ps((__m256)A4, PermTableRight[m4]);        
        m0 = __builtin_popcount(m0);
        m1 = __builtin_popcount(m1);
        m2 = __builtin_popcount(m2);
        m3 = __builtin_popcount(m3);
        m4 = __builtin_popcount(m4);        
        _mm256_storeu_pd(bottom, M0);
        bottom+=m0;
        _mm256_storeu_pd(bottom, M1);
        bottom+=m1;
        _mm256_storeu_pd(bottom, M2);
        bottom+=m2;
        _mm256_storeu_pd(bottom, M3);
        bottom+=m3;
        _mm256_storeu_pd(bottom, M4);
        bottom+=m4;        
        m0 = 4-m0;
        m1 = 4-m1;
        m2 = 4-m2;
        m3 = 4-m3;
        m4 = 4-m4;
        _mm256_storeu_pd(top, A0);
        top+=m0;
        _mm256_storeu_pd(top, A1);
        top+=m1;
        _mm256_storeu_pd(top, A2);
        top+=m2;
        _mm256_storeu_pd(top, A3);
        top+=m3;
        _mm256_storeu_pd(top, A4);
        top+=m4;        
        n-=20;
        in+=5*4;
    }
    
    
    while(n>=16)
    {
        A0 = _mm256_loadu_pd(in + 0*4);
        A1 = _mm256_loadu_pd(in + 1*4);
        A2 = _mm256_loadu_pd(in + 2*4);
        A3 = _mm256_loadu_pd(in + 3*4);   

        M0 = _mm256_cmp_pd(A0, PIVOT, 2);
        M1 = _mm256_cmp_pd(A1, PIVOT, 2);
        M2 = _mm256_cmp_pd(A2, PIVOT, 2);
        M3 = _mm256_cmp_pd(A3, PIVOT, 2);   

        m0 = _mm256_movemask_pd(M0);
        m1 = _mm256_movemask_pd(M1);
        m2 = _mm256_movemask_pd(M2);
        m3 = _mm256_movemask_pd(M3);    

        M0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableLeft[m0]);
        M1 = (__m256d)_mm256_permutevar8x32_ps((__m256)A1, PermTableLeft[m1]);
        M2 = (__m256d)_mm256_permutevar8x32_ps((__m256)A2, PermTableLeft[m2]);
        M3 = (__m256d)_mm256_permutevar8x32_ps((__m256)A3, PermTableLeft[m3]);
    
        A0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableRight[m0]);
        A1 = (__m256d)_mm256_permutevar8x32_ps((__m256)A1, PermTableRight[m1]);
        A2 = (__m256d)_mm256_permutevar8x32_ps((__m256)A2, PermTableRight[m2]);
        A3 = (__m256d)_mm256_permutevar8x32_ps((__m256)A3, PermTableRight[m3]);     

        m0 = __builtin_popcount(m0);
        m1 = __builtin_popcount(m1);
        m2 = __builtin_popcount(m2);
        m3 = __builtin_popcount(m3);     

        _mm256_storeu_pd(bottom, M0);
        bottom+=m0;
        _mm256_storeu_pd(bottom, M1);
        bottom+=m1;
        _mm256_storeu_pd(bottom, M2);
        bottom+=m2;
        _mm256_storeu_pd(bottom, M3);
        bottom+=m3;

        m0 = 4-m0;
        m1 = 4-m1;
        m2 = 4-m2;
        m3 = 4-m3;

        _mm256_storeu_pd(top, A0);
        top+=m0;
        _mm256_storeu_pd(top, A1);
        top+=m1;
        _mm256_storeu_pd(top, A2);
        top+=m2;
        _mm256_storeu_pd(top, A3);
        top+=m3;      

        n-=16;
        in+=4*4;
    }
    
    
    while(n>=12)
    {
        A0 = _mm256_loadu_pd(in + 0*4);
        A1 = _mm256_loadu_pd(in + 1*4);
        A2 = _mm256_loadu_pd(in + 2*4);

        M0 = _mm256_cmp_pd(A0, PIVOT, 2);
        M1 = _mm256_cmp_pd(A1, PIVOT, 2);
        M2 = _mm256_cmp_pd(A2, PIVOT, 2);

        m0 = _mm256_movemask_pd(M0);
        m1 = _mm256_movemask_pd(M1);
        m2 = _mm256_movemask_pd(M2); 

        M0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableLeft[m0]);
        M1 = (__m256d)_mm256_permutevar8x32_ps((__m256)A1, PermTableLeft[m1]);
        M2 = (__m256d)_mm256_permutevar8x32_ps((__m256)A2, PermTableLeft[m2]);
       
        A0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableRight[m0]);
        A1 = (__m256d)_mm256_permutevar8x32_ps((__m256)A1, PermTableRight[m1]);
        A2 = (__m256d)_mm256_permutevar8x32_ps((__m256)A2, PermTableRight[m2]);  

        m0 = __builtin_popcount(m0);
        m1 = __builtin_popcount(m1);
        m2 = __builtin_popcount(m2);

        _mm256_storeu_pd(bottom, M0);
        bottom+=m0;
        _mm256_storeu_pd(bottom, M1);
        bottom+=m1;
        _mm256_storeu_pd(bottom, M2);


        bottom+=m2;
        m0 = 4-m0;
        m1 = 4-m1;
        m2 = 4-m2;

        _mm256_storeu_pd(top, A0);
        top+=m0;
        _mm256_storeu_pd(top, A1);
        top+=m1;
        _mm256_storeu_pd(top, A2);
        top+=m2;
     
        n-=12;
        in+=3*4;
    }

    while(n>=8)
    {
        A0 = _mm256_loadu_pd(in + 0*4);
        A1 = _mm256_loadu_pd(in + 1*4);
        
        M0 = _mm256_cmp_pd(A0, PIVOT, 2);
        M1 = _mm256_cmp_pd(A1, PIVOT, 2);
        
        m0 = _mm256_movemask_pd(M0);
        m1 = _mm256_movemask_pd(M1);
        
        M0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableLeft[m0]);
        M1 = (__m256d)_mm256_permutevar8x32_ps((__m256)A1, PermTableLeft[m1]);
        
        A0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableRight[m0]);
        A1 = (__m256d)_mm256_permutevar8x32_ps((__m256)A1, PermTableRight[m1]);
        
        m0 = __builtin_popcount(m0);
        m1 = __builtin_popcount(m1);
        
        _mm256_storeu_pd(bottom, M0);
        bottom+=m0;
        _mm256_storeu_pd(bottom, M1);
        bottom+=m1;
        
        m0 = 4-m0;
        m1 = 4-m1;
        
        _mm256_storeu_pd(top, A0);
        top+=m0;
        _mm256_storeu_pd(top, A1);
        top+=m1;
        
        n-=8;
        in+=2*4;
    }
    
    while(n>=4)
    {
        A0 = _mm256_loadu_pd(in + 0*4);
        
        M0 = _mm256_cmp_pd(A0, PIVOT, 2);
        
        m0 = _mm256_movemask_pd(M0);
        
        M0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableLeft[m0]);
        
        A0 = (__m256d)_mm256_permutevar8x32_ps((__m256)A0, PermTableRight[m0]);
        
        m0 = __builtin_popcount(m0);
        
        _mm256_storeu_pd(bottom, M0);
        bottom+=m0;
        
        m0 = 4-m0;
        
        _mm256_storeu_pd(top, A0);
        top+=m0;
        
        n-=4;
        in+=1*4;
    }
    
    while(n>0)
    {
        if(in[0] <= pivot)
        {
            bottom[0] = in[0];
            bottom+=1;
            in+=1;
            n--;
        }
        else
        {
            top[0] = in[0];
            top+=1;
            in+=1;
            n--;
        }
    }
    
    //bottom[0] = pivot;
    //bottom+=1;
    
    ret_val = ((uint64_t)top-(uint64_t)tmp)/8;
    if(ret_val)
        memcpy(bottom, tmp, ret_val*8);
    
    return ret_val;
}
/*
.set pivotALU, %rcx

.set A0, %ymm0
.set A1, %ymm1
.set A2, %ymm2
.set A3, %ymm3
.set A4, %ymm4
.set A5, %ymm5
.set A6, %ymm6

.set M0, %ymm7
.set M1, %ymm8
.set M2, %ymm9
.set M3, %ymm10
.set M4, %ymm11
.set M5, %ymm12
.set M6, %ymm13

.set T, %ymm14

.set PIVOT, %ymm15

.set r0, %r8
.set r1, %r9
.set r2, %r10
.set r3, %r11
.set r4, %r15
.set r5, %r12
.set r6, %rax

# This one sorts in descending order, sort in ascending order, requires swapping the cmp operands.
.align 16
.globl qsort_AVX2
qsort_AVX2:

.set array, %rdi
.set temp_space, %rsi
.set n, %rdx

.set bottom, %r13
.set top, %r14

.Ldo_qsort:
    
    push    %r12
    push    %r13
    push    %r14
    push    %r15
    push    %rbp
    
    mov             -8(array, n, 8), pivotALU
    vbroadcastsd    -8(array, n, 8), PIVOT
    
    lea (array), bottom
    lea (temp_space), top
    dec n
    
.Lx7_loop:

    cmp $28, n
    jl  .Lx7_loop_exit

    # Load the next 28 elements
    vmovupd 32*0(array), A0
    vmovupd 32*1(array), A1
    vmovupd 32*2(array), A2
    vmovupd 32*3(array), A3
    vmovupd 32*4(array), A4
    vmovupd 32*5(array), A5
    vmovupd 32*6(array), A6
    
    # Find elements lesser-than-equal to PIVOT
    vcmppd  $2, PIVOT, A0, M0
    vcmppd  $2, PIVOT, A1, M1
    vcmppd  $2, PIVOT, A2, M2
    vcmppd  $2, PIVOT, A3, M3
    vcmppd  $2, PIVOT, A4, M4
    vcmppd  $2, PIVOT, A5, M5
    vcmppd  $2, PIVOT, A6, M6

    vmovmskpd   M0, r0
    vmovmskpd   M1, r1
    vmovmskpd   M2, r2
    vmovmskpd   M3, r3
    vmovmskpd   M4, r4
    vmovmskpd   M5, r5
    vmovmskpd   M6, r6
    
    shl $5, r0
    shl $5, r1
    shl $5, r2
    shl $5, r3
    shl $5, r4
    shl $5, r5
    shl $5, r6
    
    vmovapd .LPermTableLeft(,r0), T
    vpermps  A0, T, M0
    vmovapd .LPermTableLeft(,r1), T
    vpermps  A1, T, M1
    vmovapd .LPermTableLeft(,r2), T
    vpermps  A2, T, M2
    vmovapd .LPermTableLeft(,r3), T
    vpermps  A3, T, M3
    vmovapd .LPermTableLeft(,r4), T
    vpermps  A4, T, M4
    vmovapd .LPermTableLeft(,r5), T
    vpermps  A5, T, M5
    vmovapd .LPermTableLeft(,r6), T
    vpermps  A6, T, M6
    
    vmovapd .LPermTableRight(,r0), T
    vpermps  A0, T, A0
    vmovapd .LPermTableRight(,r1), T
    vpermps  A1, T, A1
    vmovapd .LPermTableRight(,r2), T
    vpermps  A2, T, A2
    vmovapd .LPermTableRight(,r3), T
    vpermps  A3, T, A3
    vmovapd .LPermTableRight(,r4), T
    vpermps  A4, T, A4
    vmovapd .LPermTableRight(,r5), T
    vpermps  A5, T, A5
    vmovapd .LPermTableRight(,r6), T
    vpermps  A6, T, A6
    
    popcnt  r0, r0
    popcnt  r1, r1
    popcnt  r2, r2
    popcnt  r3, r3
    popcnt  r4, r4
    popcnt  r5, r5
    popcnt  r6, r6
    
    shl $3, r0
    shl $3, r1
    shl $3, r2
    shl $3, r3
    shl $3, r4
    shl $3, r5
    shl $3, r6
    
    vmovupd M0, (bottom)
    add r0, bottom
    vmovupd M1, (bottom)
    add r1, bottom
    vmovupd M2, (bottom)
    add r2, bottom
    vmovupd M3, (bottom)
    add r3, bottom
    vmovupd M4, (bottom)
    add r4, bottom
    vmovupd M5, (bottom)
    add r5, bottom
    vmovupd M6, (bottom)
    add r6, bottom
    
    sub $32, r0
    sub $32, r1
    sub $32, r2
    sub $32, r3
    sub $32, r4
    sub $32, r5
    sub $32, r6
    
    vmovupd A0, (top)
    sub r0, top
    vmovupd A1, (top)
    sub r1, top
    vmovupd A2, (top)
    sub r2, top
    vmovupd A3, (top)
    sub r3, top
    vmovupd A4, (top)
    sub r4, top
    vmovupd A5, (top)
    sub r5, top
    vmovupd A6, (top)
    sub r6, top

    sub $28, n
    add $28*8, array
    jmp .Lx7_loop
    
.Lx7_loop_exit:
   
.Lx3_loop:

    cmp $12, n
    jl  .Lx3_loop_exit

    # Load the next 28 elements
    vmovupd 32*0(array), A0
    vmovupd 32*1(array), A1
    vmovupd 32*2(array), A2
    
    # Find elements lesser-than-equal to PIVOT
    vcmppd  $2, PIVOT, A0, M0
    vcmppd  $2, PIVOT, A1, M1
    vcmppd  $2, PIVOT, A2, M2

    vmovmskpd   M0, r0
    vmovmskpd   M1, r1
    vmovmskpd   M2, r2
    
    shl $5, r0
    shl $5, r1
    shl $5, r2
    
    vmovapd .LPermTableLeft(,r0), T
    vpermps  A0, T, M0
    vmovapd .LPermTableLeft(,r1), T
    vpermps  A1, T, M1
    vmovapd .LPermTableLeft(,r2), T
    vpermps  A2, T, M2
    
    vmovapd .LPermTableRight(,r0), T
    vpermps  A0, T, A0
    vmovapd .LPermTableRight(,r1), T
    vpermps  A1, T, A1
    vmovapd .LPermTableRight(,r2), T
    vpermps  A2, T, A2
    
    popcnt  r0, r0
    popcnt  r1, r1
    popcnt  r2, r2
    
    shl $3, r0
    shl $3, r1
    shl $3, r2
    
    vmovupd M0, (bottom)
    add r0, bottom
    vmovupd M1, (bottom)
    add r1, bottom
    vmovupd M2, (bottom)
    add r2, bottom
    
    sub $32, r0
    sub $32, r1
    sub $32, r2
    
    vmovupd A0, (top)
    sub r0, top
    vmovupd A1, (top)
    sub r1, top
    vmovupd A2, (top)
    sub r2, top

    sub $12, n
    add $12*8, array
    jmp .Lx3_loop
    
.Lx3_loop_exit:

.Lx1_loop:

    cmp $4, n
    jl  .Lx1_loop_exit

    # Load the next 28 elements
    vmovupd 32*0(array), A0
    
    # Find elements lesser-than-equal to PIVOT
    vcmppd  $2, PIVOT, A0, M0

    vmovmskpd   M0, r0
    
    shl $5, r0
    
    vmovapd .LPermTableLeft(,r0), T
    vpermps  A0, T, M0
    
    vmovapd .LPermTableRight(,r0), T
    vpermps  A0, T, A0
    
    popcnt  r0, r0
    
    shl $3, r0
    
    vmovupd M0, (bottom)
    add r0, bottom
    
    sub $32, r0
    
    vmovupd A0, (top)
    sub r0, top

    sub $4, n
    add $4*8, array
    jmp .Lx1_loop
    
.Lx1_loop_exit:

.Ls_loop:
    
    cmp $0, n
    je  .Ls_loop_exit
    
    vmovsd      (array), %xmm0
    vucomisd    %xmm15, %xmm0
    
    ja  .Lgreater
    
        vmovsd  %xmm0, (bottom)
        add $8, bottom
        add $8, array
        dec n
    
    jmp .Ls_loop
    
.Lgreater:
        vmovsd  %xmm0, (top)
        add $8, top
        add $8, array
        dec n
    
    jmp .Ls_loop
    
.Ls_loop_exit:
    vmovsd  %xmm15, (bottom)
    add $8, bottom
    
    sub temp_space, top
    shr $3, top
    mov top, %rax
    
.Lx4_copy_loop:
    cmp $16, top
    jl  .Lx4_copy_end
    
    vmovdqu 32*0(temp_space), %ymm0
    vmovdqu 32*1(temp_space), %ymm1
    vmovdqu 32*2(temp_space), %ymm2
    vmovdqu 32*3(temp_space), %ymm3
    
    vmovdqu %ymm0, 32*0(bottom)
    vmovdqu %ymm1, 32*1(bottom)
    vmovdqu %ymm2, 32*2(bottom)
    vmovdqu %ymm3, 32*3(bottom)
    
    lea 32*4(temp_space), temp_space
    lea 32*4(bottom), bottom
    sub $16, top
    jmp .Lx4_copy_loop
.Lx4_copy_end:
    
.Lx1_copy_loop:
    cmp $4, top
    jl  .Lx1_copy_end
    
    vmovdqu 32*0(temp_space), %ymm0
    
    vmovdqu %ymm0, 32*0(bottom)
    
    lea 8*4(temp_space), temp_space
    lea 8*4(bottom), bottom
    sub $4, top
    jmp .Lx1_copy_loop

.Lx1_copy_end:



    cmp $0, top
    je  .Lcopy_end
    
    mov (temp_space), %r8
    mov %r8, (bottom)
    
    lea 8(temp_space), temp_space
    lea 8(bottom), bottom
    sub $1, top
    jmp .Lx1_copy_end

.Lcopy_end:
    pop %rbp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    
    ret
    
.align 32
.LPermTableLeft:
0,0,0,0,0,0,0,0	#0
0,1,0,0,0,0,0,0	#1
2,3,0,0,0,0,0,0	#2
0,1,2,3,0,0,0,0	#3
4,5,0,0,0,0,0,0	#4
0,1,4,5,0,0,0,0	#5
2,3,4,5,0,0,0,0	#6
0,1,2,3,4,5,0,0	#7
6,7,0,0,0,0,0,0	#8
0,1,6,7,0,0,0,0	#9
2,3,6,7,0,0,0,0	#10
0,1,2,3,6,7,0,0 #11
4,5,6,7,0,0,0,0	#12
0,1,4,5,6,7,0,0	#13
2,3,4,5,6,7,0,0	#14
0,1,2,3,4,5,6,7	#15

.align 32
.LPermTableRight:
0,1,2,3,4,5,6,7	#0
2,3,4,5,6,7,0,0	#1
0,1,4,5,6,7,0,0	#2
4,5,6,7,0,0,0,0	#3
0,1,2,3,6,7,0,0	#4
2,3,6,7,0,0,0,0	#5
0,1,6,7,0,0,0,0	#6
6,7,0,0,0,0,0,0	#7
0,1,2,3,4,5,0,0	#8
2,3,4,5,0,0,0,0	#9
0,1,4,5,0,0,0,0	#10
4,5,0,0,0,0,0,0	#11
0,1,2,3,0,0,0,0	#12
2,3,0,0,0,0,0,0 #13
0,1,0,0,0,0,0,0 #14
0,0,0,0,0,0,0,0	#15
*/
