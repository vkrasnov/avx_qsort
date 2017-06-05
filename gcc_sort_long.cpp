
typedef long long int sorted_type;

#ifndef START
#define START 1000
#endif

#ifndef END
#define END 10000000
#endif

#include <string>
#include <iterator>
#include <iostream>
#include <algorithm>
#include <array>
#include <cstdlib>
#include <ctime>
#include <iomanip>
#include <vector>
#include <ipp.h>

#include "measurements.h"

extern "C" { int qsort_AVX2(sorted_type *, sorted_type *, unsigned long n); }

static void sorts(sorted_type *d, unsigned long n) {
  if (n <= 1)
    return;
  long i, j;
  for (i = 1; i < n; i++) {
    sorted_type tmp = d[i];
    for (j = i; j >= 1 && tmp < d[j - 1]; j--)
      d[j] = d[j - 1];
    d[j] = tmp;
  }
}

void my_qsort_AVX2(sorted_type *unsorted_array, sorted_type *tmp_array,
                   unsigned long n) {
  int new_n;
  while (n > 32) {
    new_n = qsort_AVX2(unsorted_array, tmp_array, n);
    n = n - new_n - 1;
    my_qsort_AVX2(&unsorted_array[n + 1], tmp_array, new_n);
  }
  sorts(unsorted_array, n);
}

#ifndef REP
#define REP (20)
#endif

int main() {

  std::srand(std::time(0));

  for (int n_elems = START; n_elems <= END; n_elems *= 10) {
    std::cout << "Number of sorted elements:\t" << n_elems << " \n";
    // Allocate space
    std::vector<sorted_type> *arr = new std::vector<sorted_type>(n_elems);
    std::vector<sorted_type> *tmp = new std::vector<sorted_type>(n_elems);

    IppSizeL sz;
    Ipp8u *buffer;
    ippsSortRadixGetBufferSize_L(n_elems, ipp64s, &sz);
    buffer = (Ipp8u *)malloc(sz);

    if (arr == NULL || tmp == NULL || buffer == NULL) {
      return 1;
    }

    // Direct point to the vector
    sorted_type *a = (sorted_type *)&*arr->begin();
    sorted_type *t = (sorted_type *)&*tmp->begin();
    double ipp_avg = 0;
    double qst_avg = 0;
    double stl_avg = 0;
    // Warmup
    for (auto &i : *arr)
      i = std::rand();
    std::sort(arr->begin(), arr->end());
    for (auto &i : *arr)
      i = std::rand();
    ippsSortRadixAscend_64s_I_L(a, n_elems, buffer);
    for (auto &i : *arr)
      i = std::rand();
    my_qsort_AVX2(a, t, n_elems);

    for (int c = 0; c < REP; c++) {
      // Populate random data
      for (auto &i : *arr)
        i = std::rand();
      MEASURE({ std::sort(arr->begin(), arr->end()); });
      stl_avg += RDTSC_total_clk;
      for (auto &i : *arr)
        i = std::rand();
      MEASURE({ ippsSortRadixAscend_64s_I_L(a, n_elems, buffer); });
      ipp_avg += RDTSC_total_clk;
      for (auto &i : *arr)
        i = std::rand();
      MEASURE({ my_qsort_AVX2(a, t, n_elems); });
      qst_avg += RDTSC_total_clk;
    }

    stl_avg /= REP;
    ipp_avg /= REP;
    qst_avg /= REP;

    std::cout << "IPP sort\tTotal cycles:   " << std::fixed << ipp_avg
              << "\tCycles/Element:    " << ipp_avg / n_elems << '\n';
    std::cout << "STL sort\tTotal cycles:   " << std::fixed << stl_avg
              << "\tCycles/Element:    " << stl_avg / n_elems << '\n';
    std::cout << "AVX sort\tTotal cycles:   " << std::fixed << qst_avg
              << "\tCycles/Element:    " << qst_avg / n_elems << '\n';

    delete arr;
    delete tmp;
    free(buffer);
  }
}
