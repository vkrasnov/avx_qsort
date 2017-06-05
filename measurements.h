/******************************************************************************/
/* Copyright(c) 2012, Intel Corp.                                             */
/* Cryptography and Algorithms Team                                           */
/* Developers and authors:                                                    */
/* Shay Gueron and Vlad Krasnov                                               */
/* IDGZ, Israel Development Center, Haifa, Israel                             */
/******************************************************************************/
/* Permission to use this code is granted.                                    */
/* Using, modifying, extracting from this code and/or algorithm(s)            */
/* requires appropriate referencing.                                          */
/******************************************************************************/
/* DISCLAIMER:                                                                */
/* THIS SOFTWARE IS PROVIDED BY THE CONTRIBUTORS AND THE COPYRIGHT OWNERS     */
/* ``AS IS''. ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED */
/* TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR */
/* PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONTRIBUTORS OR THE COPYRIGHT*/
/* OWNERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, */
/* OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF    */
/* SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS   */
/* INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN    */
/* CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)    */
/* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE */
/* POSSIBILITY OF SUCH DAMAGE.                                                */
/******************************************************************************/

#ifndef MEASURE_H
#define MEASURE_H

#ifndef RDTSC

#define MEASURE(x) (x)

#else
   
   #ifndef REPEAT     
      #define REPEAT 1
   #endif
   
   #ifndef OUTER_REPEAT
      #define OUTER_REPEAT 1
   #endif

   #ifndef WARMUP
      #define WARMUP REPEAT/4
   #endif

    unsigned long long RDTSC_start_clk, RDTSC_end_clk;
    double RDTSC_total_clk;
    double RDTSC_TEMP_CLK;
    int RDTSC_MEASURE_ITERATOR;
    int RDTSC_OUTER_ITERATOR;

inline static unsigned long get_Clks(void)
{
    unsigned hi, lo;
    __asm__ __volatile__ ("rdtscp\n\t" : "=a"(lo), "=d"(hi)::"rcx");
    return ( (unsigned long)lo)^( ((unsigned long)hi)<<32 );
}

   /* 
   This MACRO measures the number of cycles "x" runs. This is the flow:
      1) it sets the priority to FIFO, to avoid time slicing if possible.
      2) it repeats "x" WARMUP times, in order to warm the cache.
      3) it reads the Time Stamp Counter at the beginning of the test.
      4) it repeats "x" REPEAT number of times.
      5) it reads the Time Stamp Counter again at the end of the test
      6) it calculates the average number of cycles per one iteration of "x", by calculating the total number of cycles, and dividing it by REPEAT
    */      
   #define RDTSC_MEASURE(x)                                                                         \
   for(RDTSC_MEASURE_ITERATOR=0; RDTSC_MEASURE_ITERATOR< WARMUP; RDTSC_MEASURE_ITERATOR++)          \
      {                                                                                             \
         {x};                                                                                       \
      }                                                                                    		    \
	RDTSC_total_clk = 1.7976931348623157e+308;                                                      \
	for(RDTSC_OUTER_ITERATOR=0;RDTSC_OUTER_ITERATOR<OUTER_REPEAT; RDTSC_OUTER_ITERATOR++){          \
      RDTSC_start_clk = get_Clks();                                                                 \
      for (RDTSC_MEASURE_ITERATOR = 0; RDTSC_MEASURE_ITERATOR < REPEAT; RDTSC_MEASURE_ITERATOR++)   \
      {                                                                                             \
         {x};                                                                                       \
      }                                                                                             \
      RDTSC_end_clk = get_Clks();                                                                   \
      RDTSC_TEMP_CLK = (double)(RDTSC_end_clk-RDTSC_start_clk)/REPEAT;                              \
		if(RDTSC_total_clk>RDTSC_TEMP_CLK) RDTSC_total_clk = RDTSC_TEMP_CLK;				        \
	}

   #define MEASURE RDTSC_MEASURE

#endif

#endif
